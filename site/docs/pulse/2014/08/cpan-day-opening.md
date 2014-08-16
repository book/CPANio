# Opening on CPAN Day

## What is cpan.io?

CPAN.io is the brainchild of A<BOOK> and A<NEILB>. The idea came up
during one of our extended IRC sessions (extended in the sense that
we seem to pick up the conversation where it left off, sometimes with
a few days between each utterance).

We had been talking a lot about gamification, and
the success of the [once-a-week](/board/once-a/week/) game
([started](http://blog.twoshortplanks.com/2011/12/31/once-a-week-every-week/)
by A<MARKF>, with a [first leaderboard](http://onceaweek.cjmweb.net/)
by A<CJM>), and were looking for something to work on together at
the [Perl QA Hackathon in Lyon](http://act.qa-hackathon.org/qa2014/).

And so, during one of our IRC sessions, in the days leading up to the
Perl QA Hackathon, on 2014-03-11 (times in GMT, transcript slightly
edited for brevity and readability):

    23:18 <neilb> Seems to be some enthusiasm for the dashboard. Maybe a good focus point for several things at the QAH
    23:18 <BooK> yes
    23:23 <BooK> let's set some goals for the week-end...
    23:24 <BooK> - set it as a static site, generated periodically
    23:24 <BooK> - pick up a nice domain name
    23:25 <BooK> - announce it by the end of the hackathon, so it's picked up by gabor for his next newsletter
    23:25 <BooK> - I'd like to do the yearly leaderboards for once-a-week
    23:25 <neilb> you're talking about the dashboard? Or the once-a-week, or everything?! :-)
    23:26 <BooK> (dash|leader)board are just two sides of the same coin
    23:26 <BooK> it's just that the game aspect is shining more on one side
    23:27 <neilb> interesting that mainly different people have engaged with the dashboard vs the leaderboard
    23:27 <BooK> and I think the once-a-week can be part of the play-cpan
    23:27 <BooK> PlayPAN ?
    23:28 <neilb> I quite like the PlayPAN name, but my one reservation is that it doesn't have the 'CPAN' name in it. Would hopefully be a .perl.org name, which makes the perl link clear, I guess.
    23:29 <BooK> play.cpan.org or dash.cpan.org would be awesome to have
    23:29 <BooK> not sure there's someone in Lyon we can beeribe
    23:29 <BooK> (did that pun make any sense?)
    23:31 <neilb> dashboard.cpan.org would be good, but I asked about getting a .cpan.org name once before, and was told that .cpan.org is a funny beast, because of mirror sites, so generally people can't get *.cpan.org
    23:32 <neilb> cpan.dashboard.perl.org and play.dashboard.perl.org? Nah, too much of a mouthful
    23:32 <neilb> yes, the pun made sense, btw
    23:32 <BooK> ooh
    23:32 <BooK> it's probably even a neologism
    23:32 <BooK> and a portemanteaux
    23:33 <neilb> don't get carried away!
    23:33 <BooK> it's almost a word!
    23:33 <BooK> I'll lobby the dictionaries!!
    23:34 <neilb> I think you might have a neologism there. Write a blog post where you use it and define it.
    23:34 <neilb> We start referring to it and linking to it.
    23:42 <BooK> it's annoying that "play perl" was taken already
    23:42 <BooK> questhub is a very good name
    23:42 <BooK> did you know that cpan.io is free?
    23:42 <BooK> I mean, available
    23:43 <neilb> ooh, no. Hadn't thought about a different domain. Figured the SEO juice from a .perl.org would make that the right choice
    23:44 <BooK> actually, a bunch of the cpan.* domains are available
    23:47 <neilb> could then have neilb.cpan.io for my dashboard, book.cpan.io for yours, etc!
    23:48 <BooK> yup
    23:48  * neilb likes that
    23:48 <BooK> and the .io has some "data feed" feel to it
    23:50  * BooK is actually ready to click on "buy"
    23:50  * neilb just checked whether anyone has the pause id WWW
    23:50 <BooK> hehehe
    23:54 <BooK> ok, are we settled on the name? I've entered my CC info, so it's really one click away now
    23:57 <neilb> Well, I'm sure we can come up with something to do with cpan.io, even if it's not this...
    23:57 <neilb> do it! do it!
    23:57 <BooK> done
    00:05 <neilb> awesome

And so, on 2014-03-11 A<BOOK> bought the `cpan.io` domain name. During
the hackathon, we worked on [yet another CPAN leaderboard
generator](http://github.com/book/Panic/). And then, life took over,
and all went quiet...

Until CPAN Day!

## Why CPAN Day?

Actually, CPAN Day also came out of one of our IRC sessions, on 2014-06-04
(times in GMT, transcript slightly edited for brevity and readability):

    08:23 <BooK>  * kentnl proposes a once-an-hour score table just to see what happens
    08:23 <neilb> heh, was that mentioned on some IRC channel?
    08:24 <BooK> yup
    08:24 <BooK> #distzilla a few hours ago
    08:25 <BooK> actually, we should run it to see who has the longest chain, and maybe run the contest on CPAN day
    08:25 <BooK> which means... create a CPAN Day!
    08:25 <neilb> "CPAN day"?
    08:25 <BooK> there's a talk like a pirate day, a towel day, a Tau day
    08:25 <BooK> why not a CPAN day ?
    08:26 <BooK> needs some preparation, like what should Perl programmers do on CPAN day
    08:26 <BooK> but that could be a nice thing to do
    08:26 <neilb> yeah: fix bugs, update SEE ALSO, report a bug / wishlist, email thanks to other CPAN authors
    08:32  * BooK reads perlhist in search for a suitable table
    08:32 <BooK> date
    08:32 <neilb> with enough notice we could try sell people on the idea of "fix at least one bug", and try and seriously bring down the total number of bugs on CPAN.
    08:33 <BooK>  Larry   5.000          1994-Oct-17
    08:33 <BooK> actually, there's also the date of the first upload to CPAN itself
    08:34 <neilb> that's a good day to use!
    08:34 <BooK> that's still somewhat in the future (August ?)
    08:42 <BooK> that would give us a deadline for CPAN.io
    08:43 <neilb> yeah, I'll dig out the specific dist and date later
    08:43 <neilb> unless you have it to hand?
    08:47 <BooK> no
    08:49 <neilb> oldest = A/AN/ANDK/Symdump-1.20.tar.gz, released Wed Aug 16 14:12:18 1995

## Now is the day!

With A<NEILB> starting to spread the word about CPAN Day, [blogging
daily](http://blogs.perl.org/users/neilb/) about things to do on the day, A<BOOK>
decided it was a good time to actually start doing something with CPAN.io.

We have lots of ideas for the site and the game boards...
Come play the CPAN game with us, [fork cpan.io on github](http://github.com/book/CPANio/)
and send us patches and feature requests.
