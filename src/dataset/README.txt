How to create database:

1) find close webcams, run "webcams_to_download.m" to generate "webcam_list.mat".

2) use "download_webcams.py" to download from AMOS.

3) remove bad/corrupt images using "filter_images.py".

4) run "generate_siamese_pairs.m" to prepare for database making.

5) run "make_db.py" to make database.

6) run "make_mean_file.sh" to make imagenet mean
