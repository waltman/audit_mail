#!/usr/local/bin/perl
use strict;

use Mail::Audit qw(PGP KillDups);
use Text::Tabs;

my $msg = Mail::Audit->new(nomime => 1, emergency => '/home/waltman/Mail/emergency');
my $maildir = '/home/waltman/Mail/';

# Meng stuff
# if ($msg->from =~ /mengwong/ and $msg->subject =~ /reject with reason (.*)/) {
#     log_mail($msg, "Rejecting Meng mail: $1");
#     $msg->reject($1);
# }

# # check for dups, and log if we find one
# $Mail::Audit::KillDups::dupfile = "/home/waltman/.msgid-cache";
# $Mail::Audit::KillDups::cache_bytes = 30000;

# $msg->noexit(1); my $kill_dups_result = $msg->killdups; $msg->noexit(0);
# if ($kill_dups_result == 1) {
#     log_mail($msg, "KillDups: Error opening $Mail::Audit::KillDups::dupfile: $!");
# } elsif ($kill_dups_result == 2) {
#     log_mail($msg, "ignoring dup msgid " . $msg->get("Message-Id"));
#     accept_mail($msg, $maildir . "killdups");
# } elsif ($kill_dups_result == 3) {
#     log_mail($msg, "KillDups: seek failed: $!");
# }

# Split digests and feed back into audit_mail.pl
if ($msg->subject =~ /BUGTRAQ Digest/) {
    log_mail($msg, 'BUGTRAQ Digest');
    $msg->pipe('formail +2 -i "Reply-To: BUGTRAQ@securityfocus.com" -i "To: BUGTRAQ@securityfocus.com" -ds /home/waltman/bin/audit_mail.pl')
}

$msg->fix_pgp_headers;

# check for bad from addresses
if (open BMF, "/var/qmail/control/badmailfrom.wcm") {
    while (<BMF>) {
	chomp;
	accept_mail($msg, $maildir.'spam')
	    if index($msg->get('From'), $_) >= 0;
    }
    close BMF
}

my %lists = (
	     'qmail@'               => 'qmail',
	     'boston-pm@'           => 'boston.pm',
	     'london-pm@'           => 'london.pm',
	     'mutt.*@mutt.org'      => 'mutt',
	     'mutt.*@gbnet.net'     => 'mutt',
	     'BUGTRAQ@'             => 'bugtraq',
	     'yas-talk@'            => 'yas',
	     'perl5-porters@'       => 'p5p',
	     'fetchmail-announce'   => 'fetchmail_announce',
	     'plug@.*nothinbut.net' => 'plug',
	     'marsneedswomen@'      => 'marsneedswomen',
	     'leafnode-list@'       => 'leafnode',
	     'phl@lists.pm.org'     => 'perlmong',
	     'ny@lists.pm.org'      => 'ny.pm',
	     'gnome-announce-list@' => 'gnome_announce',
	     'bootstrap@perl.org'   => 'bootstrap',
	     'debian-announce'      => 'debian-announce',
	     'debian-changes'       => 'debian-changes',
	     'debian-news'          => 'debian-news',
	     'debian-security-announce' => 'debian-security-announce',
	     'debian-devel-announce' => 'debian-devel-announce',
	     'tramp-devel@'         => 'rcp',
	     'rittenhouse80211'     => '80211',
	     'beginners@perl.org'   => 'perl-beginners',
	     'yapc-planning@plover.com' => 'yapc-planning',
	     'mjd-excursions@plover.com' => 'mjd-excursions',
	     'pennband-gala@'       => 'penn-band'
	    );

for my $pattern (keys %lists) {
    accept_mail($msg, $maildir.$lists{$pattern})
	if $msg->to =~ /$pattern/i or $msg->cc =~ /$pattern/i;
}

my %sender_lists = (
		    'owner-linux-kernel'    => 'linux_kernel',
		    'owner-linux-future'    => 'linux_future',
		    'mersenne-invalid-reply-address'      => 'gimps',
		    'owner-dc@'             => 'dc.pm',
		    'owner-dcanet-outage@'  => 'dcanet-outage',
		    'owner-fslist'          => 'fslist',
		    'owner-paris-pm-list'   => 'paris.pm',
		    'yapc-plan'             => 'yapc-plan',
		    'owner-yapc-europe'     => 'yapc-europe',
		    'owner-mutt-users'      => 'mutt'
	    );

for my $pattern (keys %sender_lists) {
    accept_mail($msg, $maildir.$sender_lists{$pattern})
	if $msg->get('Sender') =~ /$pattern/i;
}

my %beenthere_lists = (
	     'plug@lists.phillylinux.org' => 'plug',
	     'pm-road-trips@'             => 'pm-road-trips',
	     'reefknot-devel@'            => 'reefknot-devel',
	     'bioperl-l@'                 => 'bioperl',
	     'cpanplus-bugs@'             => 'cpanplus-bugs'
	    );

for my $pattern (keys %beenthere_lists) {
    accept_mail($msg, $maildir.$beenthere_lists{$pattern})
	if $msg->get('X-BeenThere') =~ /$pattern/i;
}

my %from_lists = (
		  'qvc_email'           => 'iqvc',
		  'enews@xpn.org'       => 'xpn',
		 );

for my $pattern (keys %from_lists) {
    accept_mail($msg, $maildir.$from_lists{$pattern})
	if $msg->from =~ /$pattern/i;
}

my %subject_lists = (
		     'Dilbert Newsletter'   => 'dilbert',
		     '\[pennfans\]'         => 'pennfans',
		     '\[PADS\]'             => 'pads',
		     '\[yapc-lodging\]'     => 'yapc-lodging'
		    );

for my $pattern (keys %subject_lists) {
    accept_mail($msg, $maildir.$subject_lists{$pattern})
	if $msg->subject =~ /$pattern/i;
}

my %list_id_lists = (
		     'bugtraq.list-id.securityfocus.com' => 'bugtraq',
		     'pm_groups.pm.org'                  => 'pm_groups',
		     'pv.lists.LinuxForce.net'           => 'lfi'
		    );

for my $pattern (keys %list_id_lists) {
    accept_mail($msg, $maildir.$list_id_lists{$pattern})
	if $msg->get('List-Id') =~ /$pattern/i;
}

my %mailing_list_lists = (
			  'perl5-porters' => 'p5p',
			  'libtai-help'   => 'libtai',
			  'ex-ad'         => 'ex-ad',
			  'phillyjobs'    => 'phillyjobs'
			 );

for my $pattern (keys %mailing_list_lists) {
    accept_mail($msg, $maildir.$mailing_list_lists{$pattern})
	if $msg->get('Mailing-List') =~ /$pattern/i;
}

my %x_mailing_list_lists = (
			    'debian-devel' => 'debian-devel'
			   );

for my $pattern (keys %x_mailing_list_lists) {
    accept_mail($msg, $maildir.$x_mailing_list_lists{$pattern})
	if $msg->get('X-Mailing-List') =~ /$pattern/i;
}

# Messages from perl6-all go to the folder specified in the X-Mailing-List header
if ($msg->get('List-Post') =~ /perl6\-all\@perl\.org/) {
    my $perl6_list = $msg->get('X-Mailing-List-Name');
    chomp $perl6_list;
    if ($perl6_list =~ /^\s*$/)
	{
	accept_mail($msg, '/home/waltman/Maildir');
    } else {
	accept_mail($msg, $maildir.$perl6_list);
    }
}

# This should work for all ezmlm lists
if ($msg->get('List-Post') =~ /mailto:([^@]+)@/) {
    accept_mail($msg, $maildir.$1)
}

if ($msg->subject =~ /sendcellip/) {
    log_mail($msg, 'sendcellip');
    $msg->pipe('/sbin/ifconfig | grep inet | mail -s "" 4844327897@mobile.att.net')
}

if ($msg->subject =~ /sendyahooip/) {
    log_mail($msg, 'sendyahooip');
    $msg->pipe('/sbin/ifconfig | grep inet | mail -s "IP Address" wmankowski@yahoo.com')
}

if ($msg->subject =~ /sendhotmailip/) {
    log_mail($msg, 'sendhotmailip');
    $msg->pipe('/sbin/ifconfig | grep inet | mail -s "IP Address" w_mankowski@hotmail.com')
}

if ($msg->subject =~ /sendmiscip/) {
    log_mail($msg, 'sendmiscip');
    $msg->pipe('/sbin/ifconfig | grep inet | mail -s "IP Address" wmankows@misc.arsdigita.com')
}

accept_mail($msg, '/home/waltman/Maildir');

sub accept_mail {
    my ($msg, $folder) = @_;
    $folder = '/home/waltman/Maildir' if $folder =~ /^\s*$/;  # default to inbox if it's blank
    log_mail($msg, $folder);
    $msg->accept($folder);
}

sub commify {
    local $_  = shift;
    1 while s/^([-+]?\d+)(\d{3})/$1,$2/;
    return $_;
}

sub body_length {
    my $msg = shift;
    my $body = $msg->{obj}->body();
    my $body_length = 0;
    foreach (@$body) {
	$body_length += length;
    }

    return commify($body_length);
}

sub log_mail {
    my ($msg, $folder) = @_;
    my $from = $msg->get('From');

    # remove path from folder
    $folder =~ s/.*\///;

    # remove newline from "from"
    chomp $from;

    open LOG, '>>/home/waltman/Mail/mail_audit_log' or die "Can't open /home/waltman/Mail/mail_audit_log: $!";
    print LOG "From: ", $from, '  ', scalar localtime, "\n";
    print LOG " Subject: ", $msg->subject(), "\n";
    my $line3 = sprintf("  Folder: %-60s%9s\n", $folder, body_length($msg));
    print LOG unexpand($line3);
}
