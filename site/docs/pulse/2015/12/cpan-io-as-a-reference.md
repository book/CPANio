# CPAN.io as a reference site

[This post was meant to be published in June 2015, but I forgot it until
December...]

## One document should only have one source

CPAN.io started with the [once-a](/board/once-a/) games, because it was an
easy thing to do: thanks to A<CJM> and A<NEILB> existing boards, A<BOOK>
had a clear idea of what he wanted them to look like. And producing
proper [yearly boards](/board/once-a/week/releases/years.html) was a nice stretch goal.

When A<NEILB> started to work on his history of CPAN, it was immediately
obvious (to A<BOOK>) that it belonged to CPAN.io. Neil having started in a
different repository, the first step was to copy the file over. Trouble
started when people [sent](https://github.com/book/CPANio/issues/23)
[patches](https://github.com/book/CPANio/issues/24) against the CPANio
repository, instead of the cpan-history repository.

The solution to that is obviously DRY (Don't Repeat Yourself). If
the authoritative source for the "history of CPAN" document is
[that other repository](https://github.com/neilb/history-of-cpan/),
let it be.  Don't try to bring everything into the main [CPANio
repository](https://github.com/book/CPANio/).

## Passing by reference instead of copying

On May 6 2015, A<KENTNL> sent an email titled "[Documenting best practices
and the state of ToolChain guidelines using CPAN and POD](http://www.nntp.perl.org/group/perl.cpan.workers/2015/05/msg1220.html)"
to the [CPAN workers](http://lists.perl.org/list/cpan-workers.html)
mailing-list. In his email, Kent explained how he wanted to document
the best practices and policies of various Perl/CPAN projects and authors
(as living documents, because practices and policies change over time, as
we discover their limitations and figure out how to improve on them). In
the course of the discussion, A<NEILB> begged that these didn't end up on
CPAN as documentation modules, since they would be artificially limited
to the POD format as presented on <http://search.cpan.org/> and <http://metacpan.org/>.
Then A<BOOK> offered to aggregate and host these documents on <http://cpan.io/>.

So the [ref](/ref/) section of CPAN.io is now entirely made of documents that
live in other repositories. CPAN.io is only following a specific branch,
which enables the document authors to edit it according to their own
policies and practices, while CPAN.io will always pick the latest version
on the "published" branch.

As a first test, the history of CPAN document
[was removed](http://github.com/book/CPANio/commit/57ecd5380e48fc7d57507b49cad34e3521706aa6)
and [added as a reference](http://github.com/book/CPANio/commit/d88129bbc983b9d73485978a20671007ae8eb0b9),
and all the patches that were applied against CPAN.io applied to the original
repository and sent as pull request against it. They still need to be merged
at the time of this writing.

It was [quickly followed](http://github.com/book/CPANio/commit/4e8c39af712fd54883147f0b1265c54155887a03)
by the [Perl Toolchain documents](http://github.com/Perl-Toolchain-Gang/toolchain-site/),
on May 7, 2015.

[CPAN.io reference section](/ref/) is now open to publish further Perl and
CPAN policy and reference documents. They are just [a pull request away](http://github.com/book/CPANio/).

## Play on!

Come play the CPAN game with us, [fork cpan.io on github](http://github.com/book/CPANio/)
and send us patches and feature requests.
