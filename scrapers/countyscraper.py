from bs4 import BeautifulSoup
import json
import requests
import sys

def FormatAPN(apn):
	return '{0}-{1}-{2}-{3}-{4}-{5}-{6}-{7}'.format(apn[0:2], apn[2:5], apn[5:7], apn[7:9], apn[9:11], apn[11], apn[12:14], apn[14:len(apn)])

def ExtractJSONAPNS(fileloc):
	file = open(fileloc, 'r')

	extractedJSON = json.JSONDecoder().decode(file.read())

	file.close()

	apndict = dict()

	apncount = 0

	''' for geojson:
	for key in extractedJSON["features"]:
		properties = key['properties']

		parcel = properties['apn']
		apn = parcel.strip('JA')

		if len(apn) is 17:
			apndict[parcel] = '{0}-{1}-{2}-{3}-{4}-{5}-{6}-{7}'.format(apn[0:2], apn[2:5], apn[5:7], apn[7:9], apn[9:11], apn[11], apn[12:14], apn[14:len(apn)])
			apncount += 1

	'''

	for key in extractedJSON:
		parcel = key['apn']
		apn = parcel.strip('JA')

		if len(apn) is 17:
			apndict[parcel] = FormatAPN(apn)
			apncount += 1

	del extractedJSON[:]
	print("Total APNS Found: " + str(apncount))
	return apndict

def ExtractHTMLTree(URL):
	page = requests.get(URL)
	return BeautifulSoup(page.text, 'lxml')

def saveToFiles(parcels):

	JSONString = json.JSONEncoder().encode(parcels)

	print("Writing to file: ParcelData.json")
	file = open('ParcelData.json', 'w')
	file.write(JSONString)
	file.close()

#######TAX INFORMATION#######
def ScrapeTaxInfo(html):
	table = html.find("table", attrs={"id":"mTabGroup_Values_mValues_mGrid_RealDataGrid"})

	if str(type(table)) == "<type 'NoneType'>":
		return None

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
		count += 1

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

def Help():
	return "Jackson County Parcel Data Scraper\n \
			args: \n \
			--help : Prints this help statement \n \
			--file <file name> : scrapes all data from the json file listing APNS and outputs to a JSON \n \
			--apn <apn1>, <apn2>, ..., <apnN> : scrapes data for list of apns provided and outputs to a JSON \n"

def main():
	baseURL = "http://maps.jacksongov.org/PropertyReport/PropertyReport.cfm?pid="

	args = sys.argv
	apns = dict()

	if len(args) > 1:
		if args[1] == "--help":
			sys.exit(Help())
		elif args[1] == "--file":
			apns = ExtractJSONAPNS(args[2])
		elif args[1] == "--apn":
			for apn in args[2:len(args)]:
				usableapn = apn.strip('JA')
				if len(usableapn) is 17:
					apns[apn] = FormatAPN(usableapn)
		else:
			sys.exit("Invalid argument provided for list of commands use --help")
				
	else:
		sys.exit("No arguments provided for list of commands use --help")

	if len(apns) is 0:
		sys.exit("No valid APNs were provided")

	parceldict = dict()

	for key, value in apns.iteritems():

		parcelinfo = dict()
		html = ExtractHTMLTree(baseURL + value)

		parcelinfo["Property Values"] = ScrapeTaxInfo(html)
		if parcelinfo["Property Values"] is None:
			parcelinfo["Exemptions"] = None
			parcelinfo["Incentives"] = None
		else:
			parcelinfo["Exemptions"] = ScrapeExemptions(html)
			parcelinfo["Incentives"] = ScrapeIncentives(html)

		parceldict[key] = parcelinfo

	saveToFiles(parceldict)

if __name__ == "__main__":
	main()
