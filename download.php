<?php
include ('lib/simple_html_dom.php');

$rss = file_get_html('http://newalbumreleases.net/feed/');

// otvoriti prvi item, checkirati da li je novi, ako da ugrabit url
$x = 1;
$last_pub_time = file_get_contents('txts/pub_time.txt');
$pub_date_rss = $rss->find('item',0)->find('pubDate',0)->innertext;
$pub_time = strtotime($pub_date_rss);

if($pub_time > $last_pub_time)
{
	file_put_contents('txts/pub_time.txt',$pub_time);
  	foreach($rss->find('item') as $item)
	{
	 $pub_date_rss = $item->find('pubDate',0)->innertext;
	 $pub_time = strtotime($pub_date_rss);
	 //$pub_date_day = date('z', strtotime($pub_date_rss));
	 //$yesterday = date('z', strtotime('-1 day'));
	 if ($pub_time > $last_pub_time)
	    {  
		 $link = $item->find('guid',0)->innertext;
		 $html = file_get_html($link);
		 $img_src = $html->find('div.entry',0)->find('img',0)->src;
		 $a_href = $html->find('div.entry',0)->find('a',1)->href;
		 exec('wget -O /home/cika/jpgs/'.$x.'.jpg '.$img_src);
		 exec('plowdown -a email@gmail.com:password -o /home/cika/rars/ '.$a_href);
		 $x++; 
	    } 
	  
	}
}
else die("Nothing to download");
