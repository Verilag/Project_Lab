import numpy as np
from PIL import Image, ImageDraw, ImageFont

# To check if cursor == 1 for border
# Border color: 0,0,8 
# Background color: 0,0,0
# Text color: 255,255,255

def create_entry(text, width, height, center):
    file_name = "{0}_w{1}_h{2}_{3}".format(text, width, height, "center" if center else "left")
    file = open("data/" + file_name + ".txt", "w")
    print("Making entry for '{0}'".format(text))
    
    img = Image.new('RGBA', (width, height), "Black")
    fnt = font = ImageFont.load_default()
    draw = ImageDraw.Draw(img)

    # Create border of color 1,1,1
    draw.rectangle([(0, 0), (width-1, height-1)], outline=(0,0,8,255))
    
    textlen = draw.textlength(text, font)
    if not center:
        draw.line([2, 10, textlen, 10])
    offset_x = 48-textlen//2 if center else 2
    offset_y = 0
    offset = (offset_x, offset_y)
    draw.text(offset, text, font=fnt, fill=(255, 255, 255, 255))

    img.save("images/" + text + ".png")
    data = np.array(img)
    print(np.shape(data))
    #img.show()

    count = 0
    pixel_count = len(data) * len(data[0]) - 1
    file.write("wire [15:0] data [{0}:0];\n".format(pixel_count))
    
    for i in range(len(data)):
        for j in range(len(data[i])):
            r,g,b,a = data[i][j]
            file.write("assign data[o+" + str(count) + "] = ")
            file.write("16'b" + '{0:05b}'.format(r//8) + "_" + '{0:06b}'.format(g//4) + "_" + '{0:05b}'.format(b//8) + ";")
            file.write('\n')
            count += 1
    file.close()


width, height = 96, 13
'''
create_entry("Verilag", width, height-1, center=True)

create_entry("Individual", width, height, center=False)
create_entry("Audio In (JY)", width, height, center=True)
create_entry("Audio Out (DY)", width, height, center=True)
create_entry("Mouse (ZH)", width, height, center=True)
create_entry("Display (MC)", width, height, center=True)

create_entry("Personal", width, height, center=False)
create_entry("Dylan", width, height, center=True)
create_entry("Jing Yang", width, height, center=True)
create_entry("Ming Chun", width, height, center=True)
create_entry("Zheng Hong", width, height, center=True)

create_entry("team integration", width, height, center=False)
create_entry("Basic", width, height, center=True)
create_entry("Complete", width, height, center=True)
'''


