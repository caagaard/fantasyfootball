# fantasyfootball
Data modeling to optimize fantasy football drafting.  This model is specifically made for modeling ESPN standard 10 team leagues with auction drafts.  Currently only the python files for scraping the data have been committed.  R scripts for data analysis are coming soon.

**Goals for future versions**<br>
*Organize and include data analysis scripts* <br>
Stop treating player scores within a single team as independent (sharing QB WR pairs should increase variance in scoring)<br>
Stop treating consecutive weekly scores for a player as independent (injuries are a serious problem here)<br>
Allow for real-time input during the draft, and updating of player valuations<br>
Replace simple method of assigning value with Lagrangian optimization
