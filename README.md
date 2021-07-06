# luke_chopshop
This is yet another chopshop mod, but I think I have an interesting take on it.

It creates an NPC that you need to find and talk to, once you talk to him he will give you a random car from an array and a location, you need to retrieve the car and take it to a chopshop garage (all of which are configurable locations), there you can chop the car. The amount of money recieved for chopping the car depends on the damage the car has taken during travel. If you damage the car way too much you will recieve no payment.

I made the script very configurable with an easy to use config file. It also has an option for cooldown but keep in mind this wasn't tested a lot so it might be wonky.
It also uses next to no computer resources, sitting at 0.02 ms idle and 0.15ms when you are drawing the text.

This script uses pogressBar made by Poggu, which you can download <a href='https://github.com/SWRP-PUBLIC/pogressBar'>here</a>.<br>
If you decide you don't want to use these progress bars, you can simply replace all the exports in the client script with the one you use.

Feel free to edit the script to your liking, but please do not share or release your edited versions anywhere without first getting my permissions.

<h2>How to install</h2>
1. Remove the -master from the name<br>
2. Place the folder into your resources folder<br>
3. Start the script in your server.cfg<br>

If you're using pogressBar, download it, if there is remove -master in the name, put the folder in the resources folder and start it in your server.cfg
Make sure you start it before the chopshop script.
