---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: default
---
<h2>Main Links</h2>
<table>
<tr>
{% for link in site.data.main_links %}
  <td>
    <a href="{{ link.url }}" target="_blank">
      <img alt="{{ link.name }}" src="{{ site.baseurl }}/assets/images/{{ link.img }}" width="150px" height="auto">
      <br>
      {{ link.name }}
    </a>
  </td>
{% endfor %}
</tr>
</table>

<hr>

<h2>Pre Blocks Projects</h2>
<ul>
{% for link in site.data.pre_blocks_links %}
  <li>
    <a href="{{ link.url }}" target="_blank">
      {{ link.name }}
    </a>
  </li>
{% endfor %}
</ul>

<hr>

<h2>Notes</h2>
<p>
<b>Screenshot</b> - press windows key and type screenshot. Highlight area to capture and press capture button. Image is saved into Pictures/Screenshot folder.
</p>
<hr>

<h2>News</h2>
<ul>
{% for link in site.data.news_links %}
  <li>
    <a href="{{ link.url }}" target="_blank">
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
    <a href="{{ link.url }}" target="_blank">
      {{ link.name }}
    </a>
  </li>
{% endfor %}
</ul>

<hr>

<a href="{{ site.baseurl }}/easteregg" target="_blank">
    <img alt="Easter Eggs..." src="{{ site.baseurl }}/assets/images/easter-egg.png" width="50px" height="auto">
</a>
