#!/usr/bin/perl
use strict;
use warnings;
use utf8;

use File::Spec::Functions qw(catdir);
use File::Find::Rule;
use POSIX qw(strftime);
use Template;
use YAML;

sub main {
    my $chapters = YAML::LoadFile('config.yml');
    my %stats = ();
    for my $chapter (keys %{$chapters}) {
        my @solutions =
          File::Find::Rule->file()->relative->name('*.tex')
          ->in(catdir($ENV{SOURCE_DIR}, $chapter));
        $chapters->{$chapter}->{solutions} = \@solutions;
        $stats{$chapter}{exercices} = $chapters->{$chapter}->{exercices};
        $stats{$chapter}{solved}    = scalar(@solutions);
        $stats{total}{exercices}   += $chapters->{$chapter}->{exercices};
        $stats{total}{solved}      += scalar(@solutions);
    }

    my $commit = `git log --pretty=format:'%H' -n 1`;

    my $template = Template->new({   
        INCLUDE_PATH => ['lib', 'book'],
        ENCODING     => 'utf8',
        TRIM         => 1,
    });
    $template->process(
        'template.tex', {   
            chapters   => $chapters,
            stats      => \%stats,
            commit     => $commit,
            source_dir => $ENV{SOURCE_DIR},
            page_color => $ENV{PAGE_COLOR},
            text_color => $ENV{TEXT_COLOR},
        },
        '-',
        { binmode => ':utf8' },
    ) || die $template->error();
}

main();

