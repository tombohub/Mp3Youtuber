<?php

require_once('Zend/Loader.php');
Zend_Loader::loadClass('Zend_Gdata_YouTube');
Zend_Loader::loadClass('Zend_Gdata_ClientLogin');


$urls = file('urls.txt', FILE_IGNORE_NEW_LINES);
$accounts = file('accounts.txt', FILE_IGNORE_NEW_LINES);
$comments = file('comments.txt', FILE_IGNORE_NEW_LINES);

$username = strtok($accounts[0], ":");
$password = strtok(":");
	$authenticationURL= 'https://www.google.com/accounts/ClientLogin';
    $httpClient = 
    Zend_Gdata_ClientLogin::getHttpClient(
              $username = $username,
              $password = $password,
              $service = 'youtube',
              $client = null,
              $source = '', // a short string identifying your application
              $loginToken = null,
              $loginCaptcha = null,
              $authenticationURL);

  $devkey = 'devkey';
  $yt = new Zend_Gdata_YouTube($httpClient,'',null,$devkey);
  $yt->setMajorProtocolVersion(2);

$i = 0;
foreach($urls as $url)
{ 
	
	$video_id = substr($urls[$i], 31, 11);
	$comment = $comments[$i];
	echo "video id is: $video_id - ";
	echo "comment je: $comment \r\n";
    

  
  //get video entry from video ID and insert comment
  $videoEntry = $yt->getVideoEntry($video_id);
  $newComment = $yt->newCommentEntry();
  $newComment->content = $yt->newContent()->setText($comment);
  $commentFeedPostUrl = $videoEntry->getVideoCommentFeedUrl();
  $updatedVideoEntry = $yt->insertEntry($newComment, $commentFeedPostUrl,'Zend_Gdata_YouTube_CommentEntry');
  
  echo $i+1 . ". comment added  \r\n";
  $i++;
  sleep(120); 
  
}