---
layout: none
---
// Generated resources data for faceted search
const resourcesData = [
  {% for resource in site.resources %}
  {
    objectid: "{{ resource.objectid }}",
    title: {{ resource.title | jsonify }},
    alternatetitle: {{ resource.alternatetitle | jsonify }},
    url: "{{ resource.url }}",
    external_url: {{ resource.external_url | jsonify }},
    category: {{ resource.category | jsonify }},
    institution: {{ resource.institution | jsonify }},
    description: {{ resource.description | jsonify }}
  }{% unless forloop.last %},{% endunless %}
  {% endfor %}
];