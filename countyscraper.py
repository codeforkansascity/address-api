from bs4 import BeautifulSoup
import json
import requests

extractionJSON = "/wendellphillipszonesjoin.geojson"
page = requests.get('http://maps.jacksongov.org/PropertyReport/PropertyReport.cfm?pid=29-220-20-01-00-0-00-000')

soup = BeautifulSoup(page.text, 'lxml')


#######TAX INFORMATION#######
table = soup.find("table", attrs={"id":"mTabGroup_Values_mValues_mGrid_RealDataGrid"})

rows = table.find_all("tr")

years = [td.get_text() for td in rows[0].find_all("td")]
marketvalues = [td.get_text() for td in rows[1].find_all("td")]
taxablevalues = [td.get_text() for td in rows[2].find_all("td")]
assessvalues = [td.get_text() for td in rows[3].find_all("td")]

taxyears = dict()

count = 1
for year in years[1:len(years)]:
	values = dict()
	values[marketvalues[0]] = marketvalues[count]
	values[taxablevalues[0]] = taxablevalues[count]
	values[assessvalues[0]] = assessvalues[count]
	taxyears[year] = values
	++count

########EXEMPTION INFORMATION######
table = soup.find("table", attrs={"id":"mTabGroup_Exemptions_mActiveExemptions_mGrid_RealDataGrid"})

rows = table.find_all("tr")

exemptions = [None]

if len(rows) > 0:

	for row in rows:
		exemptions.append(row.get_text().strip())


##########Incentive information#######
'''

tree = html.fromstring(page.text);

data = tree.xpath('//table//tr/td/span/table//tr/td/table//tr/td/text()')

for text in data:
	print(text)


data = tree.xpath('//div/div/table//tr/td/span/span/span/text()')

cleaneddata = [None] * 10
i = 0

for text in data:
	temp = text.strip();
	if temp != "":
		cleaneddata[i] = text.strip()
		print(cleaneddata[i])
	++i

'''

