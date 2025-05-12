---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: default
---
<h2>Main Links</h2>
<ul>
{% for link in site.data.main_links %}
  <li>
    <a href="{{ link.url }}" target="_new">
      {{ link.name }}
    </a>
  </li>
{% endfor %}
</ul>