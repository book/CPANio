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

On 2014-03-11 A<BOOK> bought the `cpan.io` domain name. During
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
    08:51 <BooK> the first upload was a well-formed distribution?
    08:53 <neilb> Ah, I may have been auto filtering. I'll look later to see if there's an earlier one that my iterator skipped (almost certainly was, I'd expect)

## Now is the day!

With A<NEILB> starting to spread the word about CPAN Day, [blogging
daily](blogs.perl.org/users/neilb/) about things to do on the day, A<BOOK>
decided it was a good time to actually start doing something with CPAN.io.

We have lots of ideas for the site and the game boards...
Come play the CPAN game with us, [fork cpan.io on github](http://github.com/book/CPANio/)
and send us patches and feature requests.
