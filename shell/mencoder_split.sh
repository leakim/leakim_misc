Start from...

mencoder -ss 01:30:24 -oac copy -ovc copy in.avi -o out.avi

Replace 01:30:24 (1 hour, 30 minutes, 24 seconds) with the desired start time position.

End at...

mencoder -endpos hh:mm:ss -ovc copy -oac copy in.avi -o out.avi

Replace 00:45:00 (45 minutes) with the desired end position.

Split the movie

With the two commands above, you can for example split a movie in two bits:

mencoder -endpos 01:00:00 -ovc copy -oac copy movie.avi -o first_half.avi

mencoder -ss 01:00:00 -oac copy -ovc copy movie.avi -o second_half.avi

