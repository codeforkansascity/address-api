from bs4 import BeautifulSoup
import json
import requests

extractionJSON = "/wendellphillipszonesjoin.geojson"
page = requests.get('http://maps.jacksongov.org/PropertyReport/propertyreport.cfm?pid=28-620-08-02-00-0-00-000')

soup = BeautifulSoup(page.text, 'lxml')

parcelinfo = dict()

#######TAX INFORMATION#######
table = soup.find("table", attrs={"id":"mTabGroup_Values_mValues_mGrid_RealDataGrid"})

rows = table.find_all("tr")

years = [td.get_text() for td in rows[0].find_all("td")]
marketvalues = [td.get_text() for td in rows[1].find_all("td")]
taxablevalues = [td.get_text() for td in rows[2].find_all("td")]
assessvalues = [td.get_text() for td in rows[3].find_all("td")]

count = 1
for year in years[1:len(years)]:
	values = dict()
	values[str(marketvalues[0]).strip()] = int(marketvalues[count].replace(',', ''))
	values[str(taxablevalues[0]).strip()] = int(taxablevalues[count].replace(',', ''))
	values[str(assessvalues[0]).strip()] = int(assessvalues[count].replace(',', ''))
	parcelinfo[str(year)] = values
	++count

########EXEMPTION INFORMATION######
table = soup.find("table", attrs={"id":"mTabGroup_Exemptions_mActiveExemptions_mGrid_RealDataGrid"})

if table:

	rows = table.find_all("tr")

	exemptions = []

	if len(rows) > 0:

		for row in rows:
			print row
			exemptions.append(str(row.get_text().strip()))

	parcelinfo["Exemptions"] = exemptions
else:
	parcelinfo["Exemptions"] = ["NA"]

##########INCENTIVE INFORMATION#######
lx = soup.find_all("span", attrs={"style":"margin-left:20px;"})

lm = lx[1].find_all("span")

firstelem = True

for element in lm[0:6]:
	key = ""
	value = "null"
	if firstelem:
		key = "Capital Improvement Project"
		firstelem = False

	for a in element:
		if str(type(a)) == "<class 'bs4.element.NavigableString'>":
			a = a.strip()
			if a != "":
				value = str(a)
		elif str(type(a)) == "<class 'bs4.element.Tag'>":
			key = str(a.get_text()).strip().strip(':')

	parcelinfo[key] = value

jsonout = json.JSONEncoder().encode(parcelinfo)

print jsonout