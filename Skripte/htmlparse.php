<?php
include('simple_html_dom.php');

$rss = file_get_html('http://newalbumreleases.net/feed/');

// usporedba da li je publish datum od jucer, ako je ugrabit urlove
$x = 1;
foreach ($rss->find('item') as $item) {
    $pub_date_rss = $item->find('pubDate', 0)->innertext;
    $pub_date_day = date('z', strtotime($pub_date_rss));
    $yesterday = date('z', strtotime('-1 day'));
    if ($pub_date_day == $yesterday) {
        $link = $item->find('guid', 0)->innertext;
        $html = file_get_html($link);
        $img_src = $html->find('div.entry', 0)->find('img', 0)->src;
        $a1_href = $html->find('div.entry', 0)->find('a', 0)->href;
        $a2_href = $html->find('div.entry', 0)->find('a', 1)->href;
        echo "img src je : $img_src \n";
        echo "a1 href je : $a1_href \n";
        echo "a2 href je ; $a2_href \n";
        exec('wget -O /home/cika/jpgs/' . $x . '.jpg ' . $img_src);
        exec('plowdown -a 17198872:9racxesjl -o /home/cika/rars/ ' . $a1_href);
        exec('plowdown -a 17198872:9racxesjl -o /home/cika/rars/ ' . $a2_href);
        $x++;
    }
}