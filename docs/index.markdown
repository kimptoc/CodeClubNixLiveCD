---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: default
---
<h2>Main Links</h2>
<div id="main-links-grid" style="display: grid; gap: 10px; width: fit-content; margin: 0 auto;">
{% for link in site.data.main_links %}
  <div style="display: flex; flex-direction: column; align-items: center; border: 1px solid #ddd; padding: 10px; width: 170px;">
    <a href="{{ link.url }}" target="_blank" style="text-align: center;">
      <img alt="{{ link.name }}" src="{{ site.baseurl }}/assets/images/{{ link.img }}" width="150px" height="auto">
      <br>
      {{ link.name }}
    </a>
  </div>
{% endfor %}
</div>
<script>
(function() {
  var grid = document.getElementById('main-links-grid');
  var cols = Math.ceil(Math.sqrt(grid.children.length));
  grid.style.gridTemplateColumns = 'repeat(' + cols + ', 170px)';
})();
</script>

<hr>

<div class="tabs">
  <div class="tab-buttons">
    <button class="tab-button" onclick="openTab(event, 'news')">News</button>
    <button class="tab-button" onclick="openTab(event, 'pre-blocks')">Pre Blocks</button>
    <button class="tab-button" onclick="openTab(event, 'basic-blocks')">Basic Blocks</button>
    <button class="tab-button" onclick="openTab(event, 'scratch-projects')">Scratch Projects</button>
    <button class="tab-button" onclick="openTab(event, 'references')">References</button>
  </div>

  <div id="news" class="tab-content">
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
  </div>

  <div id="pre-blocks" class="tab-content">
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
  </div>

  <div id="basic-blocks" class="tab-content">
    <h2>Basic Blocks Projects</h2>
    <ul>
    {% for link in site.data.basic_blocks_links %}
      <li>
        <a href="{{ link.url }}" target="_blank">
          {{ link.name }}
        </a>
      </li>
    {% endfor %}
    </ul>
  </div>

  <div id="scratch-projects" class="tab-content">
    <h2>Scratch Projects</h2>
    <ul>
    {% for link in site.data.other_scratch_projects %}
      <li>
        <a href="{{ link.url }}" target="_blank">
          {{ link.name }}
        </a>
      </li>
    {% endfor %}
    </ul>
  </div>

  <div id="references" class="tab-content">
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
  </div>

</div>

<script>
function openTab(evt, tabName) {
  var i, tabcontent, tabbuttons;

  tabcontent = document.getElementsByClassName("tab-content");
  for (i = 0; i < tabcontent.length; i++) {
    tabcontent[i].style.display = "none";
  }

  tabbuttons = document.getElementsByClassName("tab-button");
  for (i = 0; i < tabbuttons.length; i++) {
    tabbuttons[i].className = tabbuttons[i].className.replace(" active", "");
  }

  document.getElementById(tabName).style.display = "block";
  evt.currentTarget.className += " active";
}

// Show News tab by default
document.addEventListener('DOMContentLoaded', function() {
  document.getElementById('news').style.display = 'block';
  document.getElementsByClassName('tab-button')[0].className += ' active';
});
</script>

<style>
.tabs {
  margin: 20px 0;
}

.tab-buttons {
  overflow: hidden;
  border-bottom: 2px solid #333;
  margin-bottom: 20px;
}

.tab-button {
  background-color: #f1f1f1;
  border: none;
  outline: none;
  cursor: pointer;
  padding: 14px 16px;
  transition: 0.3s;
  font-size: 16px;
  margin-right: 2px;
  border-top-left-radius: 5px;
  border-top-right-radius: 5px;
}

.tab-button:hover {
  background-color: #ddd;
}

.tab-button.active {
  background-color: #333;
  color: white;
}

.tab-content {
  display: none;
  padding: 20px;
  border: 1px solid #ddd;
  border-top: none;
  animation: fadeEffect 0.5s;
}

@keyframes fadeEffect {
  from {opacity: 0;}
  to {opacity: 1;}
}
</style>

<hr>

<h2>Notes</h2>
<p>
<b>Screenshot</b> - press windows key and type screenshot. Highlight area to capture and press capture button. Image is saved into Pictures/Screenshot folder.
</p>

<p>
<b>AstroPI AI Prompt</b> - Write a Python script for the Astro Pi (Sense HAT) that creates a program that lasts 30 seconds which ...
</p>

<hr>

<div id="easter-egg-link" style="display: none;">
  <a href="{{ site.baseurl }}/easteregg" target="_blank">
    <img alt="Easter Eggs..." src="{{ site.baseurl }}/assets/images/easter-egg.png" width="50px" height="auto">
  </a>
</div>

<script>
(function() {
  function checkEasterEggVisibility() {
    var now = new Date();
    var hours = now.getHours();
    var minutes = now.getMinutes();
    if (hours > 16 || (hours === 16 && minutes >= 54)) {
      document.getElementById('easter-egg-link').style.display = 'block';
    }
  }

  document.addEventListener('DOMContentLoaded', function() {
    checkEasterEggVisibility();

    document.addEventListener('keydown', function(e) {
      if (e.ctrlKey && e.altKey && e.key === 'e') {
        var el = document.getElementById('easter-egg-link');
        el.style.display = el.style.display === 'none' ? 'block' : 'none';
      }
    });
  });
})();
</script>
