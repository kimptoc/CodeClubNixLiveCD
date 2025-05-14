---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: default
---
<h2>Main Links</h2>
{% for link in site.data.main_links %}
  <span>
    <a href="{{ link.url }}" target="_new">
      <img alt="{{ link.name }}" src="{{ site.baseurl }}/assets/images/{{ link.img }}" width="150px" height="auto">
      <br>
      {{ link.name }}
    </a>
  </span>
{% endfor %}

<hr>

<h2>Notes</h2>
<p>
Screenshot - press windows key and type screenshot. Highlight area to capture and press capture button. Image is saved into Pictures/Screenshot folder.
</p>

<hr>

<h2>News</h2>
<ul>
{% for link in site.data.news_links %}
  <li>
    <a href="{{ link.url }}" target="_new">
      {{ link.name }}
    </a>
  </li>
{% endfor %}
</ul>

<hr>

<h2>References</h2>
<ul>
{% for link in site.data.reference_links %}
  <li>
    <a href="{{ link.url }}" target="_new">
      {{ link.name }}
    </a>
  </li>
{% endfor %}
</ul>

