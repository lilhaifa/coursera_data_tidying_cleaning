#!/usr/bin/perl

use Time::Local;
use File::Basename;
use strict 'refs';


# Globals definition & initialization

$SELFIE = $0;
@SELFPARTS = ();
@SFXLIST = (".pl",".txt");
$IAM = "";
$THISDATE = `date +%Y%m%d`;
$EXPARGS = 8;
$THISHOME = $ENV{"HOME"};
@SELFPARTS = fileparse($SELFIE,@SFXLIST);
$IAM = $SELFPARTS[0];
$THISDATE =~ s/\s+$//;
$LOGDEST = "$THISHOME"."/"."$IAM"."_"."$THISDATE";
$LOGFH = "";
$RXARGS = @ARGV;
$XTRAINSRC = "";
$XTESTSRC = "";
$ACTLBLSRC = "";
$YTRAINSRC = "";
$YTESTSRC = "";
$FEATSRC = "";
$ERRCOND = "";
$CURTIM = "";
%ACTMAP = ();
%XTRAINMAP = ();
%XTESTMAP = ();
%ACTRAINMAP = ();
%ACTESTMAP = ();
%SUBTRAINMAP = ();
%SUBTESTMAP = ();
$HDRSTR = "";


@SRCLIST = @ARGV; 

# subroutines pre-declaration

sub openlog;
sub now;
sub txtocsv_a;
sub txtolabel;
sub replace_a;
sub txtomap;
sub txtocsv_b;
sub merge_dset;

# first, open the log file to track msgs and errors

openlog;

# next, extract the command line arguments
#
# argument # 1 : X_train file path
# argument # 2 : X_test file path
# argument # 3 : activilty labels file path
# argument # 4 : y_train file path
# argument # 5 : y_test file path
# argument # 6 : features list file path
# argument # 7 : subject train file path
# argument # 8 : subject test file path

if( $RXARGS != $EXPARGS )
 {
  now;
  print $LOGFH "$CURTIM incorrect # of arguments. Aborting\n";
  close($LOGFH);
  exit(2);
 }

foreach $src ( @SRCLIST )
 {
  if ( ! -e $src )
   {
    print $LOGFH "$CURTIM error : source file $src not found\n";
    $ERRCOND = "1";
    last;
   }
 }
if ( $ERRCOND )
 {
  now;
  print $LOGFH "$CURTIM Error condition ! Aborting\n";
  close($LOGFH);
  exit(3);
 }

##### we start here #####

txtocsv_a($SRCLIST[0],\%XTRAINMAP);
txtocsv_a($SRCLIST[1],\%XTESTMAP);
txtolabel($SRCLIST[2]);
replace_a($SRCLIST[3],\%ACTRAINMAP);
replace_a($SRCLIST[4],\%ACTESTMAP);
txtocsv_b($SRCLIST[5]);
merge_dset($SRCLIST[6],\%SUBTRAINMAP,\%ACTRAINMAP,\%XTRAINMAP);
merge_dset($SRCLIST[7],\%SUBTESTMAP,\%ACTESTMAP,\%XTESTMAP);
now;
print $LOGFH "$CURTIM Info : Normal exit.\n";
close($LOGFH);
exit(0);

##### we finish here #####


sub openlog
 {
  my $fres;
  my $ofh;
  my $NOW = `date +%Y%m%d_%H%M%S`;

  if ( -e $LOGDEST )
    {
     $fres = open($ofh,">>",$LOGDEST);
    }
  else 
    {
     $fres = open($ofh,">",$LOGDEST);
    } 
  if ( ! $fres )
    {
     print "Unable to open log : $LOGDEST. Aborting.\n";
     exit(1);
    }
  $LOGFH = $ofh;
  print $LOGFH "$IAM : Opening log at $NOW\n\n";
  return;
 }

sub now
 {
  $thisnow = `date +%Y%m%d_%H%M%S`;
  $thisnow =~ s/\s+$//;
  $CURTIM = "["."$thisnow"."] ::";
  return;
 }

sub txtocsv_a
 {
  my $thisub = "txtocsv_a";
  my $srcfile = shift;
  my $recrf = shift;
  my @inlines = ();
  my @lparts = ();
  my @pathparts = ();
  my $srcname;
  my $pathname;

  @pathparts = fileparse($srcfile,".txt");
  $srcname = $pathparts[0];
  $pathname = $pathparts[1];
  now;
  print $LOGFH "$CURTIM $thisub : source bare file name = $srcname\n";
  $destfile = "$pathname"."$srcname".".csv"; 
  now;
  print $LOGFH "$CURTIM $thisub : destination full file name = $destfile\n";
  $ifres = open($ifh,"<",$srcfile);
  if ( ! $ifres )
   {
    print $LOGFH "$CURTIM $thisub : unable to open source file : $srcfile\n";
    exit(4);
   }
  $ofres = open($ofh,">",$destfile);
  if ( ! $ofres )
   {
    print "$CURTIM $thisub : unable to open destination file : $destfile\n";
    exit(4);
   }
  $lctr = 0;
  while( <$ifh> )
   {
    chomp($_);
    $_ =~ s/\s+$//;
    $_ =~s/^\s+//;
    $_ =~s/\s+/,/g;
    push(@inlines,$_);
    $line = $_;
    ${$recrf}{$lctr} = $line;
    @llist = split(/,/,$line);
    $llen = @llist;
    $lctr++;
   }
  $lread = @inlines;
  now;
  print $LOGFH "$CURTIM $thisub : lines read = $lread\n";
  close($ifh);
  
  foreach $plin (@inlines)
   {
    print $ofh "$plin\n";
   }
  close($ofh);
  return;
 } # txtocsv_a  

sub txtolabel
 {
  my $thisub = "txtolabel";
  my $srcfile = shift;
  my @inlines = ();
  my @lparts = ();
  my @pathparts = ();
  my $srcname;
  my $pathname;
  my $itr;

  @pathparts = fileparse($srcfile,".txt");
  $srcname = $pathparts[0];
  $pathname = $pathparts[1];
  #  now;
  #  print $LOGFH "$CURTIM $thisub : source bare file name = $srcname\n";
  #$destfile = "$pathname"."$srcname".".csv"; 
  #now;
  #print $LOGFH "$CURTIM $thisub : destination full file name = $destfile\n";
  $ifres = open($ifh,"<",$srcfile);
  if ( ! $ifres )
   {
    print $LOGFH "$CURTIM $thisub : unable to open source file : $srcfile\n";
    exit(4);
   }
   #$ofres = open($ofh,">",$destfile);
   #  if ( ! $ofres )
   #{
   # print "$CURTIM $thisub : unable to open destination file : $destfile\n";
   # exit(4);
   #}
  $lctr = 0;
  while( <$ifh> )
   {
    chomp($_);
    $_ =~ s/\s+$//;
    $_ =~s/^\s+//;
    $_ =~s/\s+/,/g;
    push(@inlines,$_);
    $line = $_;
    @llist = split(/,/,$line);
    $ACTMAP{$llist[0]} = $llist[1];
    $llen = @llist;
    $lctr++;
   }
  $lread = @inlines;
  now;
  print $LOGFH "$CURTIM $thisub : lines read = $lread\n";
  foreach $itr ( sort { $a <=> $b } keys %ACTMAP )
   {
    print $LOGFH "key = $itr, value = $ACTMAP{$itr}\n";
   }
  close($ifh);
  return;
 } # txtolabel  

sub replace_a
 {
  my $thisub = "replace_a";
  my $srcfile = shift;
  my $recrf = shift;
  my @inlines = ();
  my @lparts = ();
  my @pathparts = ();
  my $srcname;
  my $pathname;

  @pathparts = fileparse($srcfile,".txt");
  $srcname = $pathparts[0];
  $pathname = $pathparts[1];
  now;
  print $LOGFH "$CURTIM $thisub : source bare file name = $srcname\n";
  $destfile = "$pathname"."$srcname".".csv"; 
  now;
  print $LOGFH "$CURTIM $thisub : destination full file name = $destfile\n";
  $ifres = open($ifh,"<",$srcfile);
  if ( ! $ifres )
   {
    print $LOGFH "$CURTIM $thisub : unable to open source file : $srcfile\n";
    exit(4);
   }
  $ofres = open($ofh,">",$destfile);
  if ( ! $ofres )
   {
    print "$CURTIM $thisub : unable to open destination file : $destfile\n";
    exit(4);
   }
  $lctr = 0;
  while( <$ifh> )
   {
    chomp($_);
    $_ =~ s/\s+$//;
    $_ =~s/^\s+//;
    $line = $_;
    push(@inlines,$ACTMAP{$line});
    ${$recrf}{$lctr} = $ACTMAP{$line};
    $lctr++;
   }
  $lread = @inlines;
  now;
  print $LOGFH "$CURTIM $thisub : lines read = $lread\n";
  close($ifh);
  
  foreach $plin (@inlines)
   {
    print $ofh "$plin\n";
   }
  close($ofh);
  return;
 } # replace_a  

sub txtocsv_b
 {
  my $thisub = "txtocsv_b";
  my $srcfile = shift;
  my @inlines = ();
  my @lparts = ();
  my @pathparts = ();
  my $srcname;
  my $pathname;
  my $ostring = "";
  my %ftrmap = ();
  my @indx = ();
  my $itr_a;
  my $indxstr = "";

  @pathparts = fileparse($srcfile,".txt");
  $srcname = $pathparts[0];
  $pathname = $pathparts[1];
  now;
  print $LOGFH "$CURTIM $thisub : source bare file name = $srcname\n";
  $destfile = "$pathname"."$srcname".".csv"; 
  now;
  print $LOGFH "$CURTIM $thisub : destination full file name = $destfile\n";
  $ifres = open($ifh,"<",$srcfile);
  if ( ! $ifres )
   {
    print $LOGFH "$CURTIM $thisub : unable to open source file : $srcfile\n";
    exit(4);
   }
  $ofres = open($ofh,">",$destfile);
  if ( ! $ofres )
   {
    print "$CURTIM $thisub : unable to open destination file : $destfile\n";
    exit(4);
   }
  $lctr = 0;
  while( <$ifh> )
   {
    chomp($_);
    $_ =~ s/\s+$//;
    $_ =~s/^\s+//;
    $_ =~s/\s+/::/g;
    $line = $_;
    @llist = split(/::/,$line);
    $ftrmap{$llist[0]} = $llist[1];
    $lctr++;
   }
  @indx = sort { $a <=> $b } keys %ftrmap;
  $lread = @indx;
  now;
  print $LOGFH "$CURTIM $thisub : lines read = $lread\n";
  close($ifh);
  
  foreach $itr_a (@indx)
   {
    $ftrmap{$itr_a} =~ s/,/_/g;
    $ftrmap{$itr_a} =~ s/\(//g;
    $ftrmap{$itr_a} =~ s/\)//g;
    $ftrmap{$itr_a} =~ s/-/_/g; 
    print $LOGFH "key = $itr_a, value = $ftrmap{$itr_a}\n";
    $ostring = "$ostring".","."$ftrmap{$itr_a}";
    $indxstr = "$indxstr".","."$itr_a";
    $ostring =~ s/^,//;
    $indxstr =~ s/^,//;
   }
  $HDRSTR = "subject_id".","."activity_label".","."$ostring";
  now;
  print $LOGFH "$CURTIM $thisub : reconstructed string\n";
  print $LOGFH "$ostring\n";
  print $ofh "$ostring\n";
  print $ofh "$indxstr\n";
  close($ofh);
  return;
 } # txtocsv_b  

sub merge_dset
 {
  my $thisub = "merge_dset";
  my $srcfile = shift;
  my $subrf = shift;
  my $actrf = shift;
  my $measrf = shift;
  my @inlines = ();
  my @lparts = ();
  my @pathparts = ();
  my $srcname;
  my $pathname;
  my @oindx = ();
  my $itr;
  my $ofrec = "";

  @pathparts = fileparse($srcfile,".txt");
  $srcname = $pathparts[0];
  $pathname = $pathparts[1];
  now;
  print $LOGFH "$CURTIM $thisub : source bare file name = $srcname\n";
  $destfile = "$pathname"."$srcname".".csv"; 
  now;
  print $LOGFH "$CURTIM $thisub : destination full file name = $destfile\n";
  $ifres = open($ifh,"<",$srcfile);
  if ( ! $ifres )
   {
    print $LOGFH "$CURTIM $thisub : unable to open source file : $srcfile\n";
    exit(4);
   }
  $ofres = open($ofh,">",$destfile);
  if ( ! $ofres )
   {
    print "$CURTIM $thisub : unable to open destination file : $destfile\n";
    exit(4);
   }
  $lctr = 0;
  while( <$ifh> )
   {
    chomp($_);
    $_ =~ s/\s+$//;
    $_ =~s/^\s+//;
    $line = $_;
    push(@inlines,$line);
    ${$subrf}{$lctr} = $line;
    $lctr++;
   }
  $lread = @inlines;
  now;
  print $LOGFH "$CURTIM $thisub : lines read = $lread\n";
  close($ifh);

  @oindx = sort { $a <=> $b } keys %{$subrf};  
  print $ofh "$HDRSTR\n";
  foreach $itr (@oindx)
   {
    print $LOGFH "$itr\n";
    $ofrec = "${$subrf}{$itr}".","."${$actrf}{$itr}".","."${$measrf}{$itr}";
    print $ofh "$ofrec\n"; 
   }
  close($ofh);
  return;
 } # merge_dset  
