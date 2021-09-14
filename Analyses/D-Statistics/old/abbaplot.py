import toyplot
import numpy as np
import toytree
import os.path
import PIL.Image

def abbaplot(results_table, 
             tests=None, 
             names=None, 
             images=None,
             canvas=None, 
             forced_margin=0.005, 
             colored=False,
             z_threshold=5,
             points_size=1,
             xsizeylabel=0.1,
             max_value=0,
             image_ymin=0,
            ):
    """
    Method to plot multiple test results in a boxy way with bootstrap results instead of one d-statistic
    
    results_table (dataframe)
    Table with ABBA-BABA results with D, bootstd, Z, and boots columns 
    
    tests (list)
    List of indexes in the results_table to plot . Default = Length of results_table 
    
    canvas (toyplot.canvas.Canvas)
    Toyplot empty canvas. Default =  An empty canvas (1000px x 300px)
    
    forced_margin (float)
    Margin in fraction of each panel that separate each box. Default = 0.005
    
    point_size (int or float)
    Size in pixels of each dot in the scatterplot. Default = 1
    """
    
   
    if not tests:
        tests = range(results_table.shape[0])
        
    if not names:
        names = [["","",""] for i in range(results_table.shape[0])]
        
        
          #get the biggest value in points to have limits
    if max_value == 0:
        all_points = []
        for i in rtable.boots:
            all_points.extend(i.split(","))
        all_points = np.array(all_points).astype(np.float)

        max_value = max(abs(all_points))
        print(max_value)

    #define zs limits using max_value
    zmin = -max_value
    zmax = max_value
   

    # Create each subplot for each test passed in tests list
    for idx, test in enumerate(tests):
        
    
        # get numeric data
        d = results_table.D[test]
        std = results_table.bootstd[test]
        z = results_table.Z[test]
        
    
        if colored:
        # color plot if Z reach the threshold, else grey
            if z >= z_threshold:
                if d > 0:
                    fill = toyplot.color.Palette()[1]
                elif d < 0:
                    fill = toyplot.color.Palette()[0]
            else:
                fill = toyplot.color.Palette()[7]
        else:
            #Color but grayscale
            if z >= z_threshold:
                fill = "Black"
            else:
                fill = "LightGray"


        #create random points around mean with std
#         points = np.random.normal(loc=d, scale=std, size=500) 

        #get bootstrap results from result table
        points = np.array([float(i) for i in results_table.boots[test].split(",")])

#         #get the biggest value in points to have limits
#         if max(abs(points)) > max_value:
#             max_value = max(abs(points))
            
#         #define zs limits using max_value
#         zmin = -max_value
#         zmax = max_value
        
        

        #define canvas if not passed
        if not canvas:
            canvas = toyplot.Canvas(1000, 300)
            
    

            
        #global x position, considering forced_margin to separate boxes (and small box for ylabel)
        factor = (1-xsizeylabel)/len(tests)
        xsizemin = (idx * factor) + forced_margin + xsizeylabel
        xsizemax = (xsizemin + factor) - forced_margin

        #tree y position
        ysizemin = 0.0
        ysizemax = 0.3
        

        #define first area of plotting (tree)
        ax_names = canvas.cartesian(
    #                 bounds=("0%", "100%", "0%", "30%"), #xmin, xmax, ymin, ymax
                    bounds=(f"{xsizemin:.2%}", f"{xsizemax:.2%}", f"{ysizemin:.2%}", f"{ysizemax:.2%}"), #xmin, xmax, ymin, ymax
        #             grid=(2,1,0),
                    show=False,
                    padding=0,
                    margin=0,
                )

        for line, name in enumerate(reversed(names[idx])):
            ax_names.text(0,line,name, style={"fill": "black"})

#         #generate textree just for display purpuses
#         tree = toytree.rtree.unittree(ntips=3)
#         tc, ta, tm = tree.draw(
#                     axes=ax_tree, 
#                     layout='d', 
#                     edge_type='c', 
#                     xbaseline=0.5,
#                     edge_style={"stroke-width": 1},
#                     tip_labels_align=True, 
#                     tip_labels=names[idx],
#                 )

        
#         #add images if a list of tuples with images is provided
#         if images:    
#             for tip in range(tree.ntips):
#                 #get image from list of tuples
#                 image_path = images[idx][tip]
#                 #if image file exist draw it
#                 if os.path.isfile(image_path):
#                     #open image file and put in memory
#                     image = PIL.Image.open(image_path)
                    
# #                     print(xsizemax, xsizemin)
                    
#                     #calculate all bounds for positioning the image
#                     image_width = (xsizemax-xsizemin)/3
#                     tip_increment = tip * image_width
#                     image_xmin = xsizemin + tip_increment
#                     image_xmax = image_width + image_xmin
#                     image_ymin = ysizemax
#                     image_ymax = image_ymin + 0.15

    
#                     #add it to canvas
#                     canvas.image(image, bounds=(f"{image_xmin:.2%}",
#                                                 f"{image_xmax:.2%}", 
#                                                 f"{image_ymin:.2%}", 
#                                                 f"{image_ymax:.2%}"))



        if images:    
            for tip in range(3):
                #get image from list of tuples
                image_path = images[idx][tip]
                #if image file exist draw it
                if os.path.isfile(image_path):
                    #open image file and put in memory
                    image = PIL.Image.open(image_path)
                    
#                     print(xsizemax, xsizemin)
                    
                    #calculate all bounds for positioning the image
                    image_width = (xsizemax-xsizemin)
                    image_height = (ysizemax-ysizemin)/3
                    image_xmin = xsizemin
                    image_xmax = xsizemax
                    image_ymin = 0.025 * (tip+1)
                    image_ymax = 0.22 * (tip+1)
                    
                    #add it to canvas
                    canvas.image(image, bounds=(f"{image_xmin:.2%}",
                                                f"{image_xmax:.2%}", 
                                                f"{image_ymin:.2%}", 
                                                f"{image_ymax:.2%}"))



        #modify marks in the toytree draw obj to rotate tips
#         tm.tip_labels_angles=[0, 0, 0] # I think anchor is not in the center of the text, this does not work

        # plotting position update
        ysizemin = 0.4
        ysizemax = 0.95
        
        
        #show ticks only in the first box
        if idx == 0:
            showticks = True
            
            # and create a new box to put ylabel only once
            ax_label = canvas.cartesian(
            bounds=("0%", f"{xsizeylabel:.2%}", f"{ysizemin:.2%}", f"{ysizemax:.2%}"), #xmin, xmax, ymin, ymax
            show=False,
            padding=0,
            margin=0,
            )
            ax_label.text(0,0,"<span style='fill:black;font-size:120%'>D-statistic</span>", angle=90)

        else:
            showticks = False
        
        # define second area of plotting 
        ax_plot = canvas.cartesian(
    #                 bounds=("0%", "100%", "50%", "100%"), #xmin, xmax, ymin, ymax
                    bounds=(f"{xsizemin:.2%}", f"{xsizemax:.2%}", f"{ysizemin:.2%}", f"{ysizemax:.2%}"), #xmin, xmax, ymin, ymax
        #             grid=(2,1,1),
                    yshow=showticks,
                    xshow=False,
                    padding=0,
                    margin=0,
                )
        
        # remove axis lines but maintain tick numbers
        ax_plot.y.spine.show = False
        ax_plot.x.spine.show = False
        
        #draw box 
        ax_plot.rectangle( 
            0, len(points), 
            zmin, zmax, 
            style={
                "fill": "white", 
                "fill-opacity": 1.0, 
                "stroke": "grey", 
                "stroke-width": 1.5,
            },
        )


        # add 0 indicator
        ax_plot.hlines(
            0, 
            style={
                "stroke": "grey", 
                "stroke-dasharray": "2,4", 
                "stroke-width": 1,
            })

        #scatter plot
        #temporal, instead of this, here should be the actual boots and not random number arround a mean
        ax_plot.scatterplot(
            points,
            size=points_size,
            color=fill,
        )



    return canvas


def get_names_n_images_from_imap(taxon_table, imap, size_name=None, tests=None, images_dir=None, images_prefix="", images_suffix=""):
    """
    Build a list of lists with names from taxon table, checking them in the main imap to return only sp name
    """
    if not tests:
        tests = range(taxon_table.shape[0])
        
    #define item looker
    def get_key(val):
        for key, value in imap.items():
             if val in value:
                    return key
    #empty list for names
    names = []
    images = []

    #get p1 to p3 to fill names
    for i in tests:
        p3 = taxon_table.p3[i].split(",")
        p2 = taxon_table.p2[i].split(",")
        p1 = taxon_table.p1[i].split(",")
        #fill names
        names.append([get_key(p1[0])[0:size_name], get_key(p2[0])[0:size_name], get_key(p3[0])[0:size_name]])
        
        #if images dir is provided generate 
        if images_dir:
            images.append((images_dir+images_prefix+get_key(p1[0])+images_suffix, 
                           images_dir+images_prefix+get_key(p2[0])+images_suffix, 
                           images_dir+images_prefix+get_key(p3[0])+images_suffix))
    
    

    return names, images