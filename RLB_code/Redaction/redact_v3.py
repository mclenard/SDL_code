from PIL import Image
from PIL import ImageFilter
from PIL import ImageDraw
from shapely.geometry import Polygon
from shapely.geometry import MultiPolygon
from shapely.geometry import box
import shapely
import csv
import json
import io
import requests
import argparse

# Sets up command line flags to prompt user to type the name of the input file

parser = argparse.ArgumentParser(description="Take input file, scrape images, and redact")
parser.add_argument("--input_file", required=True,
                    help="Input Filename of Processed .csv")

# Read in prepared data file.
# The file the R script makes is in the form
# [subject_id, img_filename, img_url, x coords, y coords, widths, heights]
# and the indexes below assume this format.

args = parser.parse_args()
redaction_file = open(args.input_file)
file_reader = csv.reader(redaction_file)

# Go through each extracted row and save boxes for each image into a dict
# with the subject ID as the key
# This effectively 'reduces' the coordinates so that each volunteers' boxes
# for a particular page (subject ID) are collected together

coord_dict = {}
rows = []

print("\nThe following images are missing transcription boxes from at least one volunteer:")
print("-----------------------------------------------------------------------------------\n")

for row in file_reader:
    rows.append(row)   # Save rows for later use

    if row[3] == "NA":
        print(row[2])
        continue

    s_id = row[0]
    x_coords = json.loads(row[3])
    y_coords = json.loads(row[4])
    widths = json.loads(row[5])
    heights = json.loads(row[6])

    coord_list = []

    # PIL works with boxes based on the coordinate points of opposing
    # corners. (x0, y0) is the bottom-left, (x1, y1) the top-right

    for i, coord in enumerate(x_coords):
        x0 = int(x_coords[i])
        y0 = int(y_coords[i])
        x1 = int(x_coords[i] + widths[i])
        y1 = int(y_coords[i] + heights[i])

        coord_list.append((x0, y0, x1, y1))

    # Each volunteers' set of boxes is then appended to the collection as
    # a list of 4-coordinate tuples.

    if s_id in coord_dict:
        coord_dict[s_id].append(coord_list)
    else:
        coord_dict[s_id] = [coord_list]

# This section creates custom tuples containing the relevant information
# for each page, to be used in the redaction section.

print()
print("Please check the above images to see if they have data to transcribe.")
print("---------------------------------------------------------------------")

record_list = []
subject_ids = []

for row in rows:
    s_id = row[0]
    image_filename = row[1]
    image_url = row[2]

    # The conditional ensures that the information for each page is only
    # included once

    if s_id not in subject_ids:
        record_list.append((image_filename, image_url, coord_dict[s_id]))
        subject_ids.append(s_id)
    else:
        continue

# Loop through these 'records' and use a geometry package to turn the coordinates
# into 'box' objects. Use the shapely MultiPolygon object to aggregate these
# box objects into box collections, one per volunteer per page. The area to be
# kept from each image corresponds to the set-theoretic intersection of
# the MultiPolygon objects for each page - essentially only where volunteers'
# boxes overlap.

errors = []

for record in record_list:
    img_file = record[0]
    img_url = record[1]
    coords = record[2]

    mp_list = []

    for user in coords:
        box_list = []
        for tup in user:
            b = box(tup[0], tup[1], tup[2], tup[3])
            box_list.append(b)

        mp_list.append(MultiPolygon(box_list))

    try:
        if len(mp_list) == 2:
            intersect = mp_list[0].intersection(mp_list[1])
        elif len(mp_list) == 3:
            middle_step = mp_list[0].intersection(mp_list[1])
            intersect = middle_step.intersection(mp_list[2])
        else:
            intersect = mp_list[0].intersection(mp_list[0])
    except:
        print("Error performing intersection.")
        errors.append(img_url)

    # The try/except is here in testing to deal with the fact that some
    # pages may only result in a single Polygon rather than a MultiPolygon
    # 'rects' is the variable that holds the data about what is to be kept

    rects = []

    try:
        for j in range(len(intersect)):
            rects.append(intersect[j].bounds)
    except:
        rects.append(intersect.bounds)

    # Scrape the images from the photobucket using the URLs, then open
    # the images here using PIL

    r = requests.get(img_url, stream = True)

    im = Image.open(io.BytesIO(r.content))

    # Create new blank image with the same dimensions as the original -
    # I cut and paste the sections to keep from the original to this blank

    bbox = im.getbbox()
    blank = Image.new('RGB', (bbox[2], bbox[3]), (253, 253, 250))

    # Use the coordinates from 'rects' to cut & paste selected sections

    for rect in rects:
        rect = (round(rect[0]), round(rect[1]), round(rect[2]), round(rect[3]))
        print("Extracting box", rect, "in", img_file, ". . .")
        print("\n-----------------------------------")
        crop = im.crop(rect)
        blank.paste(crop, rect)

    # Save the new image, and close the image files.
    # If you would like to change the names the program saves the files with,
    # you may do so here

    blank.save("{}-redacted.jpg".format(img_file[:-4]), quality = 95)
    im.close()
    blank.close()

print()
print("The following images ran into errors and may need to be manually redacted:")
print()
for i in errors:
    print(i)
