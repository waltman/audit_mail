#!/usr/local/bin/perl
use strict;

use Mail::Audit;
use Text::Tabs;

my $msg = Mail::Audit->new;
my $maildir = '/home/waltman/Mail/';

# Split digests and feed back into audit_mail.pl
if ($msg->subject =~ /BUGTRAQ Digest/) {
    log_mail($msg, 'BUGTRAQ Digest');
    $msg->pipe('formail +2 -i "Reply-To: BUGTRAQ@securityfocus.com" -i "To: BUGTRAQ@securityfocus.com" -ds /home/waltman/bin/audit_mail.pl')
}

# If it's a PGP message, see if we need to add a header and resubmit
if (my $pgp_action = need_pgp_header($msg)) {
    log_mail($msg, "Adding PGP header, x-action = $pgp_action");
    $msg->pipe("formail -i \"Content-Type: application/pgp; format=text; x-action=$pgp_action\" -ds /home/waltman/bin/audit_mail.pl");
}

my %lists = (
	     'qmail@'               => 'qmail',
	     'boston-pm@'           => 'boston.pm',
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
	     'gnome-announce-list@' => 'gnome_announce',
	     'bootstrap@perl.org'   => 'bootstrap',
	     'emacs-rcp@'           => 'rcp'
	    );

for my $pattern (keys %lists) {
    accept_mail($msg, $maildir.$lists{$pattern})
	if $msg->to =~ /$pattern/ or $msg->cc =~ /$pattern/;
}

my %sender_lists = (
	     'owner-linux-kernel'    => 'linux_kernel',
	     'owner-linux-future'    => 'linux_future',
	     'mersenne-invalid-reply-address'      => 'gimps'
	    );

for my $pattern (keys %sender_lists) {
    accept_mail($msg, $maildir.$sender_lists{$pattern})
	if $msg->get('Sender') =~ /$pattern/;
}

my %beenthere_lists = (
	     'plug@lists.phillylinux.org' => 'plug',
	    );

for my $pattern (keys %beenthere_lists) {
    accept_mail($msg, $maildir.$beenthere_lists{$pattern})
	if $msg->get('X-BeenThere') =~ /$pattern/;
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
	     'Dilbert Newsletter'   => 'dilbert'
	    );

for my $pattern (keys %subject_lists) {
    accept_mail($msg, $maildir.$subject_lists{$pattern})
	if $msg->from =~ /$pattern/i;
}

if ($msg->subject =~ /sendcellip/) {
    log_mail($msg, 'sendcellip');
    $msg->pipe('/sbin/ifconfig | grep inet | mail -s "" 4844327897@mobile.att.net')
}

if ($msg->subject =~ /sendyahooip/) {
    log_mail($msg, 'sendyahooip');
    $msg->pipe('/sbin/ifconfig | grep inet | mail -s "" wmankowski@yahoo.com')
}

if ($msg->subject =~ /sendhotmailip/) {
    log_mail($msg, 'sendhotmailip');
    $msg->pipe('/sbin/ifconfig | grep inet | mail -s "" w_mankowski@hotmail.com')
}

accept_mail($msg, '/var/spool/mail/waltman');

sub need_pgp_header {
    my $msg = shift;

    # Does it already have the header?
    if ($msg->get('Content-Type') =~ /message\/|multipart\/|application\/pgp/) {
	return undef;
    }

    # Does it need a header?  Need to check the body...
    my $body_refs = $msg->{obj}->body();
    my $body = "";
    $body .= $_ foreach (@$body_refs);

    if ($body =~ /^-----BEGIN PGP MESSAGE-----.*
                  ^-----END PGP MESSAGE-----/msx) {
	return 'encrypt';
    }
    elsif ($body =~ /^-----BEGIN\ PGP\ SIGNED\ MESSAGE-----.*
	             ^-----BEGIN\ PGP\ SIGNATURE-----.*
	             ^-----END\ PGP\ SIGNATURE-----/msx ) {
	return 'sign';
    }
    else {
	return undef;
    }
}

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

    # remove path from folder
    $folder =~ s/.*\///;

    open LOG, '>>/home/waltman/Mail/mail_audit_log' or die "Can't open /home/waltman/Mail/mail_audit_log: $!";
    print LOG "From ", $msg->get('From ');
    print LOG " Subject: ", $msg->subject();
    my $line3 = sprintf("  Folder: %-60s%9s\n", $folder, body_length($msg));
    print LOG unexpand($line3);
}
