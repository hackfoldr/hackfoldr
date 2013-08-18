#!/usr/bin/perl
use strict;
use warnings;

use Net::GitHub;
use Getopt::Long;
our ($progname) = $0 =~ m#(?:.*/)?([^/]*)#;

my $org  = '';
my $repo = '';
my $username = '';
my $password = '';
my $is_output_token_only = 0;
my $token = '';
my $labels = '';
my $is_verbose = 0;
my $is_show_current_labels_only = 0;

sub show_usage {
    print STDERR "Error: $_[0]" . "\n\n";

    print STDERR "Usage:\n";
    print STDERR "- Access directly with github username and password\n";
    print STDERR "  $progname --org=g0v --repo=hack.g0v.tw --username=github_user --password=github_password --labels='bug|FFFFFF,important|DF0101'\n";
    print STDERR "- Access by token\n";
    print STDERR "  $progname --output-token-only --username=github_user --password=github_password > tokenfile\n";
    print STDERR "  $progname --token=`cat ./tokenfile` --org=g0v --repo=hack.g0v.tw --labels='bug|FFFFFF,important|DF0101'\n";
    print STDERR "  $progname --token=`cat ./tokenfile` --org=g0v --repo=dev --labels='bug|FFFFFF,important|DF0101'\n";
    print STDERR "- All options:\n";
    print STDERR "  --org      <string>|-o     Organization/User\n";
    print STDERR "  --repo     <string>|-r     Repository\n";
    print STDERR "  --labels   <string>|-l     Label string, format: 'name1|color1,name2|color2,...'\n";
    print STDERR "  --username <string>|-u     Github username\n";
    print STDERR "  --password <string>|-p     Github password\n";
    print STDERR "  --token    <string>|-t     Github access token\n";
    print STDERR "  --verbose          |-v     Verbose\n";
    print STDERR "  --show-current-labels      Show current labels of specific repository and quit\n";
    print STDERR "  --output-token-only        Ouput access token to STDOUT and quit\n";

    exit($_[1]);
}

GetOptions(
    'org|o=s'      => \$org,
    'repo|r=s'     => \$repo,
    'username|u=s' => \$username,
    'password|p=s' => \$password,
    'output-token-only' => \$is_output_token_only,
    'token|t=s'    => \$token,
    'labels|l=s'   => \$labels,
    'verbose|v'    => \$is_verbose,
    'show-current-labels' => \$is_show_current_labels_only,
) or show_usage('Incorrect options.', 1);


# $org and $repo are required.
if (!$is_output_token_only) {
    show_usage("Missing --org {Your org/user}", 1) unless $org;
    show_usage("Missing --repo", 1) unless $repo;
}


my $github_token;
my $oauth;
my $oauth_result;
# When not giving token, $username and $password are required.
if (!$token) {
    show_usage("Github username not set", 1) unless $username;
    show_usage("Github password not set", 1) unless $password;

    $github_token = Net::GitHub::V3->new( login => $username, pass => $password );
    $oauth = $github_token->oauth;
    $oauth_result = $oauth->create_authorization( {
            scopes => ['public_repo'], # just ['public_repo']
            note   => 'Create labels',
            } );

    if ($is_output_token_only) {
        # output token and quit.
        print $oauth_result->{token};
        exit 0;
    }
}

my $github;
if ($token) {
    $github = Net::GitHub->new(
        access_token => $token
    );
} else {
    $github = Net::GitHub->new(
        access_token => $oauth_result->{token}
    );
}

$github->set_default_user_repo($org, $repo);

my $issue = $github->issue;
my @current_labels = $issue->labels;

my @labels_to_update_tmp = split(/,/, $labels);
my @labels_to_update;

foreach (@labels_to_update_tmp) {
    my @each_label = split(/\|/, $_);
    my $name = $each_label[0];
    my $color = $each_label[1];
    my %tmp_hash = ("name" => $name, "color" => $color);
    push @labels_to_update, \%tmp_hash;
}

my %label_update_res;
my %label_create_res;
my $label_color;
my $label_name;
my $action;

#foreach (@labels_to_update) {
#        print "@{[ $_ ]}\n";
#}

if ($is_verbose || $is_show_current_labels_only) {
    # print original labels.
    print STDERR "Original labels for org:$org repo:$repo:\n";
    foreach (@current_labels) {
        print STDERR ' name:' . $_->{name} . ', color:' . $_->{color} . "\n";
    }
}

exit 0 if $is_show_current_labels_only;

foreach (@labels_to_update) {
    $label_name = $_->{name};
    $label_color = $_->{color};
    $action = 'create';

    # find if the label name already exists in repo.
    foreach (@current_labels) {
        if ($_->{name} eq $label_name) {
            $action = 'update';
            last;
        }
    }

    if ( $action eq 'update' ) {
        # update
        print STDERR 'Updating label ' . $label_name . '...'; 
        %label_update_res  = $issue->update_label( $label_name, {
                "color" => $label_color
                } );
        print STDERR "\n";
        print STDERR "@{[ %label_update_res ]}\n" if $is_verbose;
        
    } else {
        # create
        print STDERR 'Creating label ' . $label_name . '...'; 
        %label_create_res = $issue->create_label( {
                "name" => $label_name,
                "color" => $label_color
            } );
        print STDERR "\n";
        print STDERR "@{[ %label_create_res ]}\n" if $is_verbose;
    }
}


0;
