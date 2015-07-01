from lxml import html
import requests

page = requests.get('http://maps.jacksongov.org/PropertyReport/PropertyReport.cfm?pid=29-220-20-01-00-0-00-000')

tree = html.fromstring(page.text);


data = tree.xpath('//div/div/table//tr/td/span/span/span/text()')

cleaneddata = [None] * 10
i = 0

for text in data:
	temp = text.strip();
	if temp != "":
		cleaneddata[i] = text.strip()
		print(cleaneddata[i])
	++i

print();


