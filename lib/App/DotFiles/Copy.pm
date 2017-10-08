package App::DotFiles::Copy;

use Moo;
use Config::ZOMG;
use File::Spec;
use File::chdir;
use Dir::Self;
use JSON::XS qw/encode_json/;

has qw/config/ => ( is => 'lazy' );

has opts => ( is => 'ro' );

sub _merge {
    my ($l1, $l2) = @_;

    my %seen;
    return [grep( !$seen{$_}++, @$l1, @$l2)];
}

sub _build_config {
    my ($self) = @_;

    my $opts = $self->opts;

    my $config_file = $opts->{config_file} || File::Spec->catfile(__DIR__, q{dotfiles.json});

    my $config = Config::ZOMG->new(file => $config_file);
    my $config_hash = $config->load;

    foreach my $key (qw/git_url dir_name/) {
        $config_hash->{$key} = $opts->{$key} if $opts->{$key};
    }

    if ($opts->{files}) {
        if (!$config_hash->{files}) {
            # just copy the given
            $config_hash->{files} = $opts->{files};
        } else {
            # preserve both
            $config_hash->{files} = _merge($config_hash->{files}, $opts->{files});
        }
    }

    $config_hash->{dir_name} ||= File::Spec->catfile($ENV{'HOME'}, '.dotfiles');

    if (!$config_hash->{git_url}) {
        die "Please set --git_url (or add in config)\n";
    }

    return $config_hash;
}

sub save_config {
    my ($self) = @_;

    my $opts = $self->opts;
    my $config_file = $opts->{config_file} || File::Spec->catfile(__DIR__, q{dotfiles.json});

    open (my $fh, '>', $config_file) or die "$!";
    print $fh encode_json($self->config);
    close $fh;
}

sub _run_in_dir {
    my ($self, $dir, $callback) = @_;
    local $CWD = $dir;

    $callback->();
}

sub _run_cmd {
    my ($self, $cmds) = @_;

    foreach my $cmd (@$cmds) {
        system($cmd) == 0 or die "system $cmd: $?";
    }
}


sub checkout_or_update {
    my ($self) = @_;

    my $config = $self->config;

    my $git_url = $config->{git_url};
    my $dir_name = $config->{dir_name};

    if (-d $dir_name) {
        $self->_run_in_dir($dir_name, sub {
                $self->_run_cmd(["git pull origin master"]);
            });
    } else {

        eval {
            $self->_run_cmd(["git clone $git_url $dir_name"]);
        };
        if ($@) {
            if (mkdir $dir_name) {
                $self->_run_in_dir($dir_name, sub {

                        $self->_run_cmd([
                            "touch .gitignore",
                            "git init",
                            "git add .",
                            "git commit -m 'initial commit'",
                            "git remote add origin $git_url",
                            "git push origin master",
                        ]);
                    });
            } else {
                die "checkout_or_update: can't create $dir_name : $!\n";
            }
        }
    }
}

sub update_repo {
    my ($self) = @_;
    my $config = $self->config;

    $self->_run_in_dir($config->{dir_name}, sub {
            # What?
            if (`git status` !~ /working directory clean/) {
                $self->_run_cmd([
                        'git add .',
                        q{git commit -m "Edited dotfiles: } . (scalar localtime) . q{"},
                        'git push origin master',
                    ]);
            }
        });
}

sub do_copy {
    my ($self) = @_;

    $self->checkout_or_update;

    my $config = $self->config;

    if (!$config->{files}) {
        die("no files given, try --file=.., or alter the config?");
    }

    my @files = @{$config->{files}};

    foreach my $file (@files) {
        $file = File::Spec->catfile($ENV{'HOME'}, $file);
        $self->_run_cmd(["cp -r $file " . $config->{dir_name}]);
    }

    $self->update_repo;
}

sub do_update {
    my ($self) = @_;

    $self->checkout_or_update;

    my $config = $self->config;

    if (!$config->{files}) {
        die("no files given, try --file=.., or alter the config?");
    }

    my @files = @{$config->{files}};

    foreach my $file (@files) {
        my $src = File::Spec->catfile($config->{dir_name}, $file);
        my $dest = $ENV{'HOME'};

        eval {
            $self->_run_cmd(["cp -r $src $dest"]);
        };
        if ($@) {
            warn "Couldn't recover $file ($src to $dest) : " . $@ . "\n";
        }
    }
}

1;
