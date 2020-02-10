---
title: Democritus of Nicomedia's Garland Problem
---

At Athenaeus 15.670f, the dining philosopher Democritus of Nicomedia introduces the following problem (tr. S. Douglas Olson):

> The most holy Plato in [Book VII of the Laws (819b)](http://www.perseus.tufts.edu/hopper/text?doc=Perseus%3Atext%3A1999.01.0166%3Abook%3D7%3Asection%3D819b), moreover, poses a puzzle that involves garlands, which deserves to be explicated. The philosopher puts it as follows: distributions of certain apples and garlands, with the same quantities working for both larger and smaller numbers of people. This is what Plato said, but what he means is something along the following lines: Try to identify a single number that will allow everyone, including the last person to enter the room, to have an equal number of apples or garlands. I claim, then, that the number 60 can provide up to six guests with an equal share. For I am aware that initially (1.4e, quoting Archestr. fr. 4 Olson–Sens = SH 191) we said that a dinner party should consist of no more than five people; but that we are more numerous than the grains of sand is obvious. The number 60, at any rate, will be large enough for a party that includes up to six guests, in the following way. The first man came to the party and took 60 garlands; when the second man came in, he gave him half, and they each had 30; when the third man came in, they divided them all up again and had 20 apiece; so too they shared them with the fourth man and had 15 apiece, and with the fifth man and had 12 apiece, and with the sixth man and had 10 apiece. In this way an equal division of the wreaths can be maintained.

A fun puzzle is to consider what the general solution to this problem would be, that is:

> For *n* people, what’s the smallest number of garlands *x* that can be distributed evenly among them for each 1..*n* group as people arrive?

Answer (spoilers) below the mark.

---

The smallest number of garlands *x* is the [least common multiple](https://en.wikipedia.org/wiki/Least_common_multiple) of the set (1..*n*). As you might expect if you've tried to work this out for larger numbers of people, the number of garlands required grows quite rapidly. Would the Ancient Greeks have been able to solve a problem like this? Well, Euclid's *Elements* 7.34 outlines a method for finding the least common multiple of two numbers (building on the Euclidean greatest common divisor algorithm at *Elements* 7.1-2), and the remainder of book seven is spent making more general solutions for the least common multiple of arbitrary sets, so it seems feasible that someone could recognize its usefulness for this and extend its application to this problem.

Now, since Democritus says "that we are more numerous than the grains of sand is obvious" ("ὅτι δ᾿ ἡμεῖς [ψαμμακόσιοι](https://logeion.uchicago.edu/%CF%88%CE%B1%CE%BC%CE%BC%CE%B1%CE%BA%CF%8C%CF%83%CE%B9%CE%BF%CE%B9) ἐσμὲν δῆλον"), how many guests would you need before the number of garlands required was greater than the number of grains of sand on Earth?

Once you get to *n* = 43, `9.4 x 10^18` garlands are required, which is greater than the `7.5 x 10^18` grains of sand reckoned [here](https://www.npr.org/sections/krulwich/2012/09/17/161096233/which-is-greater-the-number-of-sand-grains-on-earth-or-stars-in-the-sky).

Of course, reckoning the number of grains of sand was also an ancient mathematical pursuit—[Archimedes reckoned the number of grains of sand you could fit into the Aristarchean universe to be `10^63`](https://en.wikipedia.org/wiki/The_Sand_Reckoner). How many guests would you need before the number of garlands exceeded this number as well? Additionally, an observant reader will have already noticed that Democritus said the number of *guests* is more numerous than the grains of sand, not the number of *garlands*. I leave these calculations as an exercise for the reader.
