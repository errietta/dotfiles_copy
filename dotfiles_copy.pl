use warnings;
use strict;

use Getopt::Long;
use Pod::Usage;

use App::DotFiles::Copy;

=head1 NAME

App::DotFiles::Copy

=head1 DESCRIPTION

Hack to git-ify dotfiles

=head1 SYNOPSIS

dotfiles_copy.pl -files .vimrc --copy --save

dotfiles_copy.pl --update

dotfiles_copy.pl --help

=head1 OPTIONS

=over

=item push (previously copy)

Push local dotfiles to repo

=item pull (previously update)

Pull local dotfiles from repo

=item file

Files to copy, can also be given in config_file

=item config_file

Path to config file, optional, defaults to 'dotfiles_copy.json' in the same
directory as this app.

=item git_url

The repo, can also be given in config

=item dir_name

Where the repo is, by default ~/.dotfiles

=item save

Save given options to config.

=back

=cut


my ($copy, $update, $save, $config_file, @files, $git_url, $dir_name,  $help);

GetOptions(
    "copy|push"         => \$copy,
    "update|pull"       => \$update,
    "save"              => \$save,
    "config_file=s"     => \$config_file,
    "file=s"            => \@files,
    "git_url=s"         => \$git_url,
    "dir_name=s"        => \$dir_name,
    "help"              => \$help,
)  or pod2usage(2);

if (!$copy && !$update && !$help) {
    pod2usage(2);
}

if ($help) {
    pod2usage(-verbose => 1);
}

my $app = App::DotFiles::Copy->new(
    opts => {
        git_url     => $git_url,
        dir_name    => $dir_name,
        files       => scalar @files ? \@files : undef,
        config_file => $config_file,
    }
);

if ($save) {
    $app->save_config;
}

if ($copy) {
    print "Initialising copy of local files...\n";
    $app->do_copy;
    print "Success\n";
} elsif ($update) {
    print "Initialising recovery of dotfiles from repo..\n";
    $app->do_update;
    print "Success\n";
}
