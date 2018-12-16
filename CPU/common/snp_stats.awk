BEGIN {mismatch_both=0;mismatch=0;both=0;either=0;complex=0;complex_both=0;ref=0;alt=0;ref_both=0;alt_both=0;trans=0;} {

  split($12,pos1,":");
  split($13,pos2,":");

  if (pos1[3]!="") print pos1[3] > "/dev/stderr";
  if (pos1[6]!="") print pos1[6] > "/dev/stderr";
  if (pos2[3]!="") print pos2[3] > "/dev/stderr";
  if (pos2[6]!="") print pos2[6] > "/dev/stderr";

  if (($12 ~ /maternal/ && $12 ~ /paternal/) && ($13 ~ /maternal/ && $13 ~ /paternal/)) {
    complex_both+=1;

  } else if (($12 ~ /maternal/ && $12 ~ /paternal/) || ($13 ~ /maternal/ && $13 ~ /paternal/)) {
    complex+=1;

  } else if ($12 ~ /maternal/ && $13 ~ /maternal/) {
      alt_both+=1;
      both+=1;

  } else if ($12 ~ /maternal/ || $13 ~ /maternal/){

      alt+=1
      either+=1

      if ($12 ~ /paternal/ || $13 ~ /paternal/) {

        trans+=1;
        ref+=1;

      }

  } else if ($12 ~ /paternal/ && $13 ~ /paternal/) {

      ref_both+=1;
      both+=1;

  } else if ($12 ~ /paternal/ || $13 ~ /paternal/){

      ref+=1
      either+=1

      if ($12 ~ /maternal/ || $13 ~ /maternal/) {

        trans+=1;
        alt+=1;

      }

  } else {
    if ($12 ~ /mismatch/ && $13 ~ /mismatch/) {
      mismatch_both+=1;
    } else {
      mismatch+=1;

    }

  }


  } END { OFS="\t"
    print "Total reads overlapping SNPs", either + both + complex + complex_both + mismatch + mismatch_both
    print "Overlap SNP on one read end", either + mismatch + complex
    #print "\t Reference", ref
    #print "\t Alternative", alt
    print "\t Neither", mismatch
    print "Overlap SNP on both read ends", both + mismatch_both + complex_both
    #print "\t Reference agreement", ref_both
    #print "\t Alternative agreement", alt_both
    print "\t Reference/Alternative disagreement", trans
    print "\t Neither", mismatch_both
    print "Total Reference contacts", ref + ref_both
    print "Total Alternative contacts", alt + alt_both
}
