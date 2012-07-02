:: Original world designed by Tor Frick (torfrick.com)
:: Modified in UDK-2012-05 editor (added collision-frame to some objects)
:: Difficulty: Medium-Hard (teams should be able to navigate multiple floors)
:: #Robots: 4 robots
:: #Victims: 4 Victims 
:: no fog, but highly dynamic lighting effects
:: no AirRobot allowed (will not fit through the doorways)
:: Groundrobots are a little bit too big (world should be scaled a factor ~1.25-1.5).
:: Victims are scaled down to fit in the world (but are now a little bit too small)
:: Both Kenaf and P3AT fit through the doorways, although it is a bit tight.
:: Kenaf can go up the small stairs and can descent from the big stairs.
:: 
:: Robot Tags: Robot1,Robot2,Robot3,Robot4
:: Comstation Tag: ComStation
@echo off

..\Binaries\win32\udk Robocup2012-Preliminary3?game=USARBotAPI.BotDeathMatch -log 