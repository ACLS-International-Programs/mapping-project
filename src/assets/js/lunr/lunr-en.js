---
layout: none
---

var idx = lunr(function () {
  this.field('title')
  this.field('alternatetitle')
  this.field('institution')
  this.field('category')
  this.field('description')
  this.field('tags')
  this.ref('id')

  this.pipeline.remove(lunr.trimmer)

  for (var item in store) {
    this.add({
      title: store[item].title,
      alternatetitle: store[item].alternatetitle,
      institution: store[item].institution,
      category: store[item].category,
      description: store[item].description,
      tags: store[item].tags,
      id: item
    })
  }
});

$(document).ready(function() {
  $('input#search').on('keyup', function () {
    var resultdiv = $('#results');
    var query = $(this).val().toLowerCase();
    var result =
      idx.query(function (q) {
        query.split(lunr.tokenizer.separator).forEach(function (term) {
          q.term(term, { boost: 100 })
          if(query.lastIndexOf(" ") != query.length-1){
            q.term(term, {  usePipeline: false, wildcard: lunr.Query.wildcard.TRAILING, boost: 10 })
          }
          if (term != ""){
            q.term(term, {  usePipeline: false, editDistance: 1, boost: 1 })
          }
        })
      });
    resultdiv.empty();
    resultdiv.prepend('<p class="results__found">'+result.length+' {{ site.data.ui-text[site.locale].results_found | default: "Result(s) found" }}</p>');
    for (var item in result) {
      var ref = result[item].ref;
      var title = store[ref].title;
      if (store[ref].hasOwnProperty('alternatetitle') && store[ref].alternatetitle) {
        title += ' ('+store[ref].alternatetitle+')';
      }

      var details = ''; 
      // if (store[ref].hasOwnProperty('institution') && store[ref].institution) {
      //   details += store[ref].institution + '<br>';
      // } 
      if (store[ref].hasOwnProperty('category') && store[ref].category) {
        details += '<span style="display: block;padding:.5em 0 .5em 0;color: #2b3aa8;font-size:.8em;"># '+store[ref].category + '</span>';
      }
      if (store[ref].hasOwnProperty('description') && store[ref].description) {
        details += store[ref].description.split(" ").splice(0,20).join(" ");
      }
      if(store[ref].teaser){
        var searchitem =
          '<div class="list__item">'+
            '<article class="archive__item" itemscope itemtype="https://schema.org/CreativeWork">'+
              '<h2 class="archive__item-title" itemprop="headline">'+
                '<a href="'+store[ref].url+'" rel="permalink">'+title+'+</a>'+
              '</h2>'+
              '<p class="archive__item-excerpt" itemprop="description">'+details+'...</p>'+
            '</article>'+
          '</div>';
      }
      else{
    	  var searchitem =
          '<div class="list__item">'+
            '<article class="archive__item" itemscope itemtype="https://schema.org/CreativeWork">'+
              '<h2 class="archive__item-title" itemprop="headline">'+
                '<a href="'+store[ref].url+'" rel="permalink">'+title+'</a>'+
              '</h2>'+
              '<p class="archive__item-excerpt" itemprop="description">'+details+'...</p>'+
            '</article>'+
          '</div>';
      }
      resultdiv.append(searchitem);
    }
  });
});
