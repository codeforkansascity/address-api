from bs4 import BeautifulSoup
import json
import pprint
import requests

def ExtractJSONAPNS(fileloc):
	file = open(fileloc, 'r')

	extractedJSON = json.JSONDecoder().decode(file.read())

	file.close()

	apndict = dict()

	for key in extractedJSON["features"]:
		properties = key['properties']

		parcel = properties['apn']
		apn = parcel.strip('JA')

		if len(apn) is 17:
			apndict[parcel] = '{0}-{1}-{2}-{3}-{4}-{5}-{6}-{7}'.format(apn[0:2], apn[2:5], apn[5:7], apn[7:9], apn[9:11], apn[11], apn[12:14], apn[14:len(apn)])
			print apndict[parcel]
	extractedJSON.clear()
	return apndict

def ExtractHTMLTree(URL):
	page = requests.get(URL)
	return BeautifulSoup(page.text, 'lxml')

#######TAX INFORMATION#######
def ScrapeTaxInfo(html):
	table = html.find("table", attrs={"id":"mTabGroup_Values_mValues_mGrid_RealDataGrid"})

	rows = table.find_all("tr")

	years = [td.get_text() for td in rows[0].find_all("td")]
	marketvalues = [td.get_text() for td in rows[1].find_all("td")]
	taxablevalues = [td.get_text() for td in rows[2].find_all("td")]
	assessvalues = [td.get_text() for td in rows[3].find_all("td")]

	yeardict = dict()

	count = 1
	for year in years[1:len(years)]:
		values = dict()
		values[str(marketvalues[0]).strip()] = int(marketvalues[count].replace(',', ''))
		values[str(taxablevalues[0]).strip()] = int(taxablevalues[count].replace(',', ''))
		values[str(assessvalues[0]).strip()] = int(assessvalues[count].replace(',', ''))
		yeardict[str(year)] = values
		++count

	return yeardict

########EXEMPTION INFORMATION######
def ScrapeExemptions(html):
	table = html.find("table", attrs={"id":"mTabGroup_Exemptions_mActiveExemptions_mGrid_RealDataGrid"})

	if table:

		rows = table.find_all("tr")

		exemptions = []

		if len(rows) > 0:

			for row in rows:
				exemptions.append(str(row.get_text().strip()))

		return exemptions
	else:
		return ["NA"]



##########INCENTIVE INFORMATION#######
def ScrapeIncentives(html):
	lx = html.find_all("span", attrs={"style":"margin-left:20px;"})

	lm = lx[1].find_all("span")

	incentivesDict = dict()

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

		incentivesDict[key] = value

	return incentivesDict



def main():
	baseURL = "http://maps.jacksongov.org/PropertyReport/PropertyReport.cfm?pid="

	apns = ExtractJSONAPNS("wendellphillipszonesjoin.geojson")


	parcellist = []

	count = 0

	for key, value in apns.iteritems():
		if count is 10:
			break

		parcelinfo = dict()
		html = ExtractHTMLTree(baseURL + value)
		print(baseURL + value)	
		parcelinfo["APN"] = key
		parcelinfo["Property Values"] = ScrapeTaxInfo(html)
		parcelinfo["Exemptions"] = ScrapeExemptions(html)
		parcelinfo["Incentives"] = ScrapeIncentives(html)

		parcellist.append(parcelinfo)
		++count

	jsonout = json.JSONEncoder().encode(parcellist)

	pprint.pprint(jsonout)


if __name__ == "__main__":
	main()



#print jsonout
