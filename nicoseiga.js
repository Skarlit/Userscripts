// ==UserScript==
// @name         Nico Seiga simplified
// @namespace    https://github.com/Skarlit/Userscripts
// @version      0.1
// @description  Simpler view for nico seiga
// @author       Skarlit
// @match        http://seiga.nicovideo.jp/seiga/*
// @grant        none
// ==/UserScript==

document.addEventListener('DOMContentLoaded', function() {
  var illustWrapper = document.querySelector('.illust_wrapper');
  var illustMain = document.querySelector('.illust_main');
  var picFrame = document.createElement('iframe');
  illustMain.style.height = window.innerHeight + 'px';
  picFrame.src = document.querySelector('#illust_link').href;
  picFrame.frameborder = '0';
  picFrame.style.height = window.innerHeight + 'px';
  picFrame.style.width = '100%';
  picFrame.style.border = 'none';
  illustWrapper.style.width = '100%';
  illustWrapper.style.height = window.innerHeight + 'px';
  var newWrapper = illustWrapper.cloneNode()
  illustWrapper.style['display'] = 'none';
  newWrapper.appendChild(picFrame);
  illustWrapper.parentNode.insertBefore(newWrapper, illustWrapper);
  var style = document.createElement('style');

  style.innerHTML = '#related_info { margin: 0; width: 100%} .related_info_main {width: auto !important; float: initial !important;} #detail { margin: 0; width: 100%}';

  document.body.appendChild(style);
});