#!/usr/local/bin/perl
use strict;

# $Log: audit_mail.pl,v $
# Revision 1.17  2001/05/24 22:34:45  waltman
# Log the From: line instead of the From_ line
#
# Revision 1.16  2001/05/20 15:25:12  waltman
# Added london.pm
#
# Revision 1.15  2001/05/16 02:42:29  waltman
# Changed regex comparisons to be case-insensitive
#
# Revision 1.14  2001/04/25 01:58:35  waltman
# DOH!  Check $msg->subject when checking subject.
#
# Revision 1.13  2001/04/25 01:55:16  waltman
# Commented out call to fix_pgp_headers, as it doesn't seem to be working.
#
# Revision 1.12  2001/04/25 01:32:43  waltman
# Added bnt list
#
# Revision 1.11  2001/04/21 03:10:57  waltman
# Added new entries for pads, pennfans, and 80211.
#
# Revision 1.10  2001/02/23 03:11:34  waltman
# Replaced my old PGP code with the PGP plugin which adds the correct headers.
#
# Revision 1.9  2001/01/30 03:56:23  waltman
# Uncommented out PGP header code.
#
# Removed -d switch from formail when adding PGP header, since when it's
# there it wants to muck around with some fields in the body that (I
# guess) it thinks are mail headers.
#
# Revision 1.8  2001/01/28 20:00:17  waltman
# commented out code to add pgp header, since it seems to sometimes
# change the message
#
# Revision 1.7  2000/12/29 03:19:20  waltman
# Added debian-devel-announce
#
# Revision 1.6  2000/10/26 00:37:32  waltman
# Added ny.pm list
# Remove RBL checking, since it never seems to catch anything
#
# Revision 1.5  2000/10/26 00:36:17  waltman
# Added RBL checking and a bunch of Debian lists
#

use Mail::Audit qw(PGP);
use Text::Tabs;

my $msg = Mail::Audit->new;
my $maildir = '/home/waltman/Mail/';

# Split digests and feed back into audit_mail.pl
if ($msg->subject =~ /BUGTRAQ Digest/) {
    log_mail($msg, 'BUGTRAQ Digest');
    $msg->pipe('formail +2 -i "Reply-To: BUGTRAQ@securityfocus.com" -i "To: BUGTRAQ@securityfocus.com" -ds /home/waltman/bin/audit_mail.pl')
}

#$msg->fix_pgp_headers;

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
	     'redhat-announce'      => 'redhat_announce',
	     'phl@lists.pm.org'     => 'perlmong',
	     'ny@lists.pm.org'      => 'ny.pm',
	     'gnome-announce-list@' => 'gnome_announce',
	     'bootstrap@perl.org'   => 'bootstrap',
	     'debian-announce'      => 'debian-announce',
	     'debian-changes'       => 'debian-changes',
	     'debian-laptop'        => 'debian-laptop',
	     'debian-news'          => 'debian-news',
	     'debian-security-announce' => 'debian-security-announce',
	     'debian-devel-announce' => 'debian-devel-announce',
	     'debian-user'          => 'debian-user',
	     'emacs-rcp@'           => 'rcp',
	     'rittenhouse80211'     => '80211',
	     'beginners@perl.org'   => 'perl-beginners'
	    );

for my $pattern (keys %lists) {
    accept_mail($msg, $maildir.$lists{$pattern})
	if $msg->to =~ /$pattern/i or $msg->cc =~ /$pattern/i;
}

my %sender_lists = (
	     'owner-linux-kernel'    => 'linux_kernel',
	     'owner-linux-future'    => 'linux_future',
	     'mersenne-invalid-reply-address'      => 'gimps'
	    );

for my $pattern (keys %sender_lists) {
    accept_mail($msg, $maildir.$sender_lists{$pattern})
	if $msg->get('Sender') =~ /$pattern/i;
}

my %beenthere_lists = (
	     'plug@lists.phillylinux.org' => 'plug',
	    );

for my $pattern (keys %beenthere_lists) {
    accept_mail($msg, $maildir.$beenthere_lists{$pattern})
	if $msg->get('X-BeenThere') =~ /$pattern/i;
}

my %from_lists = (
	     'iqvc_mail'           => 'iqvc',
	     'redhat-announce'     => 'redhat_announce'
	    );

for my $pattern (keys %from_lists) {
    accept_mail($msg, $maildir.$from_lists{$pattern})
	if $msg->from =~ /$pattern/i;
}

my %subject_lists = (
		     'Dilbert Newsletter'   => 'dilbert',
		     '\[pennfans\]'         => 'pennfans',
		     '\[PADS\]'             => 'pads',
		     '\[bitsntits\]'        => 'bnt'
		    );

for my $pattern (keys %subject_lists) {
    accept_mail($msg, $maildir.$subject_lists{$pattern})
	if $msg->subject =~ /$pattern/i;
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

# Messages from perl6-all go to the folder specified in the X-Mailing-List header
if ($msg->get('List-Post') =~ /perl6\-all\@perl\.org/) {
    my $perl6_list = $msg->get('X-Mailing-List-Name');
    chomp $perl6_list;
    accept_mail($msg, $maildir.$perl6_list);
}

accept_mail($msg, '/var/spool/mail/waltman');

sub accept_mail {
    my ($msg, $folder) = @_;
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
    print LOG " Subject: ", $msg->subject();
    my $line3 = sprintf("  Folder: %-60s%9s\n", $folder, body_length($msg));
    print LOG unexpand($line3);
}
