#!/usr/bin/python3

DATA_FILE = "./data/nhtsa-tesla-fire.txt"
OUTPUT_FILE = "./output.tsv"

import re
from dateutil.parser import parse


all_reports = []
current = []
with open(DATA_FILE, "r") as fh:
    all_lines = fh.readlines()
    for line in all_lines:
        line = line.rstrip()
        # if blank line
        if re.match("^\s*$", line):
            continue
        current.append(line)
        if re.match("^Request Research", line):
            all_reports.append(current)
            current = []

def remove_until_first_colon(something):
    return re.sub("^.+?: ", "", something)


with open(OUTPUT_FILE, "w") as ofh:

    all_fields = ["components", "id", "date", "location", "crash", "fire", "injuries", "deaths"]
    ofh.write("\t".join(all_fields))
    ofh.write("\n")

    for report in all_reports:
        if len(report) != 14:
            continue
        garb1, components, id, date, location, garb2, garb3, crash, fire, injuries, deaths, note, *rest = report

        components = remove_until_first_colon(components)
        id = remove_until_first_colon(id)
        date = re.sub("Incident Date (\w+) (\d+), (\d+).*", "\\3-\\1-\\2", date)
        date = parse(date)
        date = date.strftime('%Y-%m-%d')
        location = re.sub("^Consumer Location ", "", location)
        crash = remove_until_first_colon(crash)
        fire = remove_until_first_colon(fire)
        injuries = remove_until_first_colon(injuries)
        deaths = remove_until_first_colon(deaths)
        note = re.sub("\\t", "", note)

        all_fields = [components, id, date, location, crash, fire, injuries, deaths]

        ofh.write("\t".join(all_fields))
        ofh.write("\n")

print("done")
