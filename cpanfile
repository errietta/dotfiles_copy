requires 'Moo', '0';
requires 'Config::ZOMG', '0';
requires 'File::Spec', '0';
requires 'File::chdir', '0';
requires 'Dir::Self', '0';
requires 'Getopt::Long', '0';
requires 'JSON::XS', '0';
requires 'Pod::Usage', '0';

on 'test' => sub {
    requires 'Test::More', '0';
};
