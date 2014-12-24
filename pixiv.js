// ==UserScript==
// @name         Download button for pixiv
// @namespace    https://github.com/Skarlit/Userscripts
// @version      0.1
// @description  Download button for pixiv.
// @author       Skarlit
// @match        http://www.pixiv.net/member_illust.php?mode=medium&illust_id=*
// @grant        none
// ==/UserScript==

$(document).ready(function() { 
  var image = $('.original-image');
  if (image.length > 0) {
      var url = image[0].dataset['src'];
      var downloadBtn = document.createElement('a');
      downloadBtn.href = url;
      downloadBtn.download = url.split('/').pop();
      downloadBtn.classList.add('_button');
      downloadBtn.textContent = 'Download';
      $('.bookmark-container')[0].appendChild(downloadBtn);
  }
});