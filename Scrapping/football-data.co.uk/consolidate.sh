#/bin/sh

rm -f data.csv
rm -f m*.csv

files=`ls *.csv`

for file in $files; do
    ncolm=`head -1 $file | sed 's/[^,]//g' | wc -c`
    if [ "$(grep -c ,Time, $file)" -ge 1 ]; then
        (cut -d, -f2,4-$ncolm $file) > tmp$file
    else
        (cut -d, -f2-$ncolm $file) > tmp$file
    fi
done

tmp_files=`ls tmp*.csv`    

for file in $tmp_files; do
    filename=`echo $file | sed -re 's/tmp(.*).csv$/\1/'`
    
    sed "1 s/^/Season,/" $file | sed "1 ! s/^/$filename,/" | sed "1 ! s/+//g" > m$filename.csv
done

rm tmp*.csv

m_files=`ls m*.csv`    

python3 merge.py