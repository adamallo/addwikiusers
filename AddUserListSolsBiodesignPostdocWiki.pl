#!/opt/local/bin/perl5.22
use strict;
use warnings;
use WWW::Mechanize;
use Data::Dumper;
use Term::ReadKey;

scalar @ARGV == 1 or die "Usage script plain_text_email_per_line";
my $file=$ARGV[0];
(-f $file) or die "Input file $file is not accesible\n";

my $url ='http://postdocs.biodesign.asu.edu/index.php?title=Special:UserLogin&returnto=Main+Page&returntoquery=';
my $url2 = 'http://postdocs.biodesign.asu.edu/index.php?title=Special:UserLogin/signup';
my $m = WWW::Mechanize->new();
my $i=1;
my $logged=0;
while ($i<=5 and $logged==0)
{ 

	print "Enter a wiki user name with admin privileges: ";
	my $name=<STDIN>;
	chomp $name;
	print "Enter your password: ";
	ReadMode('noecho');
	my $password=<STDIN>;
	ReadMode(0);
	chomp $password;

	if(($name eq "") or ($password eq "")) 
	{
		print "\nEmpty fields are not allowed\n";
	}
	else
	{
		#print "Debug:$name,$password\n";
		$m->get($url);
		$m->form_number(1);
		$m->field('wpName',$name);
		$m->field('wpPassword',$password);
	
		my $response = $m->submit();
		$m->get('/index.php?title=Special:UserLogin/signup');
		my $form=$m->form_number(1);
		my $input=$form->find_input("wpCreateaccountMail");
		if (! defined $input)
		{
			print "\nYour user or password are not correct or your user does not have admin privileges. Attempt $i of 5";
			if ($i ==5)
			{
				print ". You have reached the maximum number of attempts.\n"
			}
			else
			{
				print ", try again.\n";
			}
		}
		else
		{
			print "\nYou are logged in. Starting the process:\n";
			$logged=1;
		}
	}
	$i=$i+1;
} 

open(my $INPUTFILE,"<$file");
my @emails=<$INPUTFILE>;
close($INPUTFILE);
for my $email (@emails)
{
	chomp($email);
	unless ($email=~/.+\@.+\..+/)
	{
		die "The line $email does not resembles an email address. Check your input file!\n";
	}
}
for my $email (@emails)
{
	chomp($email);
	my $name=$email;
	$name=~s/(.*)@.*/$1/;
	$m->get('/index.php?title=Special:UserLogin/signup');
	$m->form_number(1);
	$m->field('wpName',$name);
	$m->field('wpCreateaccountMail',"1");
	$m->field('wpEmail',$email);
	$m->submit();
	print "User $name with email $email added to the wiki\n";
	sleep 3;
}
exit;
