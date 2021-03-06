#!/usr/local/bin/perl
use strict;
use warnings;
use lib qw(/usr/share/perl5);

use Mail::Audit qw(PGP KillDups);
use Text::Tabs;
use Mail::SpamAssassin;

my $msg = Mail::Audit->new(nomime => 1, emergency => '/home/waltman/Mail/emergency', no_log => 1);
my $maildir = '/home/waltman/Mail/';
my $inbox = '/home/waltman/Maildir';
my $imap = '/home/waltman/imap';
my $spamassassin_semaphore = 'home/waltman/.sa_skip';

unless (-e $spamassassin_semaphore) {
    my $raw = $msg->as_string;
    my $spamtest = Mail::SpamAssassin->new( { rules_filename => '/usr/share/spamassassin',
                                              site_rules_filename => '/etc/spamassassin',
                                            } );
    my $mail = $spamtest->parse($raw);
    my $status = $spamtest->check($mail);

    if ($status->is_spam()) {
        my $spam = $status->rewrite_mail();
        my @lines = map { "$_\n" } split /\n/, $spam;

        my $spam_msg = Mail::Audit->new(nomime => 1,
                                        emergency => '/home/waltman/Mail/emergency',
                                        no_log => 1,
                                        data => \@lines);
        accept_mail($spam_msg, $maildir . "spam");
    }
}

# accept_mail($msg, $maildir . "spam") if $msg->get('X-Spam-Flag') =~ /YES/i;

$msg->fix_pgp_headers;

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
	     'pennband-gala@'       => 'penn-band',
             'phillyos2@'           => 'phillyos2',
             'jschwart@voicenet.com' => 'secret_cinema',
             'awsff-owner@'         => 'awsff',
             'dns@'                 => 'djbdns'
	    );

for my $pattern (keys %lists) {
    accept_mail($msg, $maildir.$lists{$pattern})
	if $msg->to =~ /$pattern/i or $msg->cc =~ /$pattern/i;
}

my %sender_lists = (
		    'owner-linux-kernel'    => 'linux_kernel',
		    'owner-linux-future'    => 'linux_future',
		    'mersenne-users'        => 'gimps',
		    'owner-dc@'             => 'dc.pm',
		    'dc-bounces\+waltman'   => 'dc.pm',
		    'owner-dcanet-outage@'  => 'dcanet-outage',
		    'owner-fslist'          => 'fslist',
		    'owner-paris-pm-list'   => 'paris.pm',
		    'yapc-plan'             => 'yapc-plan',
		    'owner-yapc-europe'     => 'yapc-europe',
		    'owner-mutt-users'      => 'mutt',
		    'owner-ip@'             => 'ip',
                    'owner-spf-discuss@'    => 'spf-discuss',
                    'owner-ny@'             => 'ny.pm',
                    'owner-or-announce@'    => 'or-announce',
                    'owner-or-talk@'        => 'or-talk',
                    'owner-tor-relays@'     => 'tor-relays',
                    'awsff@'                => 'awsff',
                    'wn-similarity@'        => 'wn-similarity',
                    'ibi@lists.upenn.edu'   => 'pbflist',
                    'opencv@'               => 'opencv',
                    'IMAGEJ@'               => 'imagej'
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
	     'cpanplus-bugs@'             => 'cpanplus-bugs',
             'prime@'                     => 'gimps'
	    );

for my $pattern (keys %beenthere_lists) {
    accept_mail($msg, $maildir.$beenthere_lists{$pattern})
	if $msg->get('X-BeenThere') =~ /$pattern/i;
}

my %from_lists = (
		  'qvc_email'           => 'iqvc',
		  'qvc_mail'            => 'iqvc',
		  'qvcemail'            => 'iqvc',
		  'enews@xpn.org'       => 'xpn',
                  'wiredcampus@chronicle.com' => 'chronicle',
                  'daily-html@chronicle.com'  => 'chronicle',
                  'circulation@chronicle.com' => 'chronicle',
                  'partner@chroniclepartners.com'  => 'chronicle',
                  'epitek'                 => 'epitek',
                  'flavie.dibou@gmail.com' => 'epitek',
		 );

for my $pattern (keys %from_lists) {
    accept_mail($msg, $maildir.$from_lists{$pattern})
	if $msg->from =~ /$pattern/i;
}

my %to_lists = (
                  'epitek'                 => 'epitek',
                  'flavie.dibou@gmail.com' => 'epitek',
		  'waltman-acm@'	   => 'acm',
		  'waltman-adc'		   => 'adc',
		  'waltman-alumni'	   => 'alumni',
		  'waltman-facebook'	   => 'facebook',
		  'waltman-mlb'		   => 'mlb',
		  'waltman-obama'	   => 'obama',
		  'waltman-orkut'	   => 'orkut',
		  'waltman-postmaster' 	   => 'postmaster',
		  'waltman-twitter'	   => 'twitter',
		  'waltman-webmaster'      => 'webmaster',
               );

for my $pattern (keys %to_lists) {
    accept_mail($msg, $maildir.$to_lists{$pattern})
	if $msg->to =~ /$pattern/i;
}

my %subject_lists = (
		     'Dilbert Newsletter'   => 'dilbert',
		     '\[PADS\]'             => 'pads',
		     '\[yapc-lodging\]'     => 'yapc-lodging',
                     'get_feeds.pl'         => 'news_feeds',
                     '\[Fail2Ban\]'         => 'fail2ban',
		    );

for my $pattern (keys %subject_lists) {
    accept_mail($msg, $maildir.$subject_lists{$pattern})
	if $msg->subject =~ /$pattern/i;
}

my %list_id_lists = (
		     'bugtraq.list-id.securityfocus.com' => 'bugtraq',
		     'pm_groups.pm.org'                  => 'pm_groups',
		     'pv.lists.LinuxForce.net'           => 'lfi',
		     'announce.pennclubofboston.org'     => 'pennclubofboston',
                     'abe-pm.mail.pm.org'                => 'abe.pm',
                     'abe-pm.pm.org'                     => 'abe.pm',
                     'dfw-pm.pm.org'                     => 'dfw.pm',
                     'philadelphia-pm.pm.org'            => 'phl.pm',
                     'spf-discuss'                       => 'spf-discuss',
                     'fslist'                            => 'fslist',
                     'london.pm.groups.perlists.pm'      => 'london.pm',
                     'gnupg-announce.gnupg.org'          => 'gnupg-announce',
                     'talk.phillyonrails.org'            => 'phillyonrails'
		    );

for my $pattern (keys %list_id_lists) {
    accept_mail($msg, $maildir.$list_id_lists{$pattern})
	if $msg->get('List-Id') =~ /$pattern/i;
}

my %mailing_list_lists = (
			  'perl5-porters'   => 'p5p',
			  'libtai-help'     => 'libtai',
			  'ex-ad'           => 'ex-ad',
			  'phillyjobs'      => 'phillyjobs',
			  'pennfans'        => 'pennfans',
			  'BrynMawrSpecFic' => 'BrynMawrSpecFic',
                          'im2000'          => 'im2000',
                          'geohack'         => 'geohack',
                          'bordshake'       => 'bordshake',
                          'pennrmug'        => 'pennrmug',
                          'PhillyGeek'      => 'PhillyGeek',
                          'johnkerry-87'    => 'kerry'
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
	accept_mail($msg, $inbox);
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

if ($msg->subject =~ /testimapqp/) {
    log_mail($msg, 'imap');
    $msg->resend('waltman-imap', {port => 2525});
}

accept_mail($msg, $inbox);

sub accept_mail {
    my ($msg, $folder) = @_;
    $folder = $inbox if $folder =~ /^\s*$/;  # default to inbox if it's blank
    $folder = $inbox unless -e $folder;      # don't autocreate new folders
    log_mail($msg, $folder);
#     report_new_folder($folder) unless -e $folder;

#    $msg->accept($imap, { noexit => 1 }) if $folder eq $inbox;
#    $msg->accept($folder);
   if ($folder eq $inbox) {
       #       $msg->resend('waltman-imap', {port => 2525});
       $msg->accept($inbox, $imap);
   } else {
       $msg->accept($folder);
   }
}

sub commify {
    local $_  = shift;
    1 while s/^([-+]?\d+)(\d{3})/$1,$2/;
    return $_;
}

sub body_length {
    my $msg = shift;
    my $body = $msg->body();
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

sub report_new_folder {
    my $folder = shift;

    unless (open(SENDMAIL, "|/usr/lib/sendmail -oi -t -odq")) {
	warn "Can't fork for sendmail: $!\n";
	return;
    }
    print SENDMAIL <<"EOF";
From: audit_mail.pl <waltman\@mawode.com>
To: Walt Mankowski <waltman>
Subject: Creating new mail folder ($folder)

I just created a new mail folder -- $folder
You might want to add it to your .muttrc

Hugs,
audit_mail.pl

EOF
    close(SENDMAIL)     or warn "sendmail didn't close nicely";
}

