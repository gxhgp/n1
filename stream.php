<?php
$url = 'https://www.stream-link.org/stream-link.m3u';
$file = zxCurl($url);
$fix_file = str_replace('https://sc', 'https://dsgdfr.serv00.net/servi.php?url=https://sc', $file);
//$fix_file = str_replace('https://sc', 'https://s8.630106.xyz/servi.php?url=https://sc', $file);
//$fix_file = str_replace('https://sc', 'https://s8.mtvpry.nyc.mn/servi.php?url=https://sc', $file);
$fix_file = str_replace('#EXTM3U','#EXTM3U x-tvg-url="http://content.stream-link.org/epg/guide.xml"',$fix_file);
$fix_file = str_replace('title="TVB','title="香港電視',$fix_file);
$fix_file = str_replace('title="香港電視娛樂','title="香港電視',$fix_file);
$fix_file = str_replace('title="RTHK','title="香港電視',$fix_file);
$fix_file = str_replace('title="奇妙電視','title="香港電視',$fix_file);
$fix_file = str_replace('title="鳳凰衛視','title="中國',$fix_file);
$fix_file = str_replace('title="新加坡','title="星日韓',$fix_file);
$fix_file = str_replace('title="日韓','title="星日韓',$fix_file);

echo $fix_file;
//file_put_contents('stream.m3u',$fix_file);

function zxCurl($url, $headers = null)
{
    $headers = [
    'User-Agent: TiviMate/4.5.1 (Linux; Android 10)'
    ];
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    curl_setopt($ch, CURLOPT_TIMEOUT, 100);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
    $data = curl_exec($ch);
    curl_close($ch);
  header('Content-type: application/octet-stream');
  return $data;
  
    
}


?>
