#!/usr/bin/perl

#A wonderful game of innocent gambling

#use strict; #dslkrjheoir£$£$^%%$^$£"%$
use warnings;
use Scalar::Util qw(looks_like_number);
use Term::Spinner;

$init=0;

if ($init == 0) {
	$init=1; #assign values only once
	$balance = 10; #starting credit
	$currentBet = 0; #amount currently being bet
	$optionChosen = 0; #number/colour player chooses
	$colourOfOptionChosen = "NULL"; #colour of the number chosen by player. Not the colour they typed in
	$colour = "NULL"; #colour roulette ball lands on
	$gameOver = 0; #keeps the game loop going
	$roulette = 0; #roulette number
	$count = 1; #number of rounds played
	$numberOrColour = 0; #splits logic based on if string or int is inputted into optionChosen
	$wheelSpin = 50000;
}

#if current bet is the same as highest bet, add current bet to balance and set current bet to 1
sub playCheck{
	if ($balance <= 0){ #does player have money? If not, game over.
		print "You are out of money. GET OUTTA MY CLUB!";
		$gameOver=1;
	}
}

#confirms current amount, asks for bet and sorts values
sub placeBet{
	print "\n\n\nYour current balance is: \$",$balance, "\n";
	print "Place your bets please.\n";
	print "How much do you want to bet?\n";
	$currentBet = <STDIN>;
	$currentBet =~ tr/0-9//dc;
	print "Pick a number to bet on. Type red, black or green to bet on that colour.\n";
	$optionChosen = <STDIN>;
	$optionChosen = uc $optionChosen;
	chomp($optionChosen);
	if ($optionChosen eq "RED" || $optionChosen eq "GREEN" || $optionChosen eq "BLACK"){
		$numberOrColour = 1;
	} else {
		$numberOrColour = 0;
		$optionChosen =~ tr/0-9//dc;	#culls any letters or special characters
		if ($optionChosen==0){ #determines colour of number roulette ball has landed on
			$colourOfOptionChosen="GREEN";
		} elsif($optionChosen % 2 == 1){
			$colourOfOptionChosen="RED";
		} else {
			$colourOfOptionChosen="BLACK";
		}
	}
}

#roulette table picks random number between 0 and 36
#number is deterined to be a winner/loser
sub spin{
		print "Placing bet number ",$count++, "\n";
		print"Spinning Wheel\n";
		my $spinner = Term::Spinner->new();
  		while($wheelSpin > 0) {
     	$spinner->advance();
      	$wheelSpin--;
  		}
 		undef $spinner; # clears final spinner output by default.
 		$wheelSpin = 50000;
		$roulette=int(rand(37)); #spin the whell to get a number between 0-36
		if ($roulette==0){ #determines colour of number roulette ball has landed on
			$colour="GREEN";
		} elsif($roulette % 2 == 1){
			$colour="RED";
		} else {
			$colour="BLACK";
		}

		print "Ball lands on ", $roulette," ", $colour,"\n";
}

#if number is loser current bet is deducted from balance
#if number is winner, increase balance by winnings
sub winLose{
		if ($numberOrColour == 1){
			if ($optionChosen eq $colour){
				print "You have bet on ", $optionChosen,"\n";
				print "That means... Your colour wins!\n";
				$balance += $currentBet * 2;			
			} else {
				print "That means... You lose!\n";
				$balance -= $currentBet;
			}
		}
		elsif ($numberOrColour == 0){
			if ($roulette == $optionChosen){
				print "You have bet on ", $optionChosen," ", $colourOfOptionChosen,"\n";
				print "That means... Your number wins!\n";
				$balance += $currentBet * 35;
			} else {
				print "That means... You lose!\n";
				$balance -= $currentBet;
			}
		}
	}

#main game routine
playCheck; #prevents game starting with 0 in balance
while ($gameOver==0){
	placeBet;
	if (looks_like_number($currentBet)){
		if ($numberOrColour == 1 || looks_like_number($optionChosen)){
			spin;
			winLose;
		} else {
		print "That's not a number, sir. Please try again \n";
		}
	} else {
		print "That's not a number, sir. Please try again \n";
	}
	playCheck;
}