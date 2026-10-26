/**
 * 小鹿兒紫微斗數・Web 應用前端交互核心 (App.js)
 */

(function () {
  'use strict';

  // MARK: - 應用狀態管理 (State)
  const state = {
    currentUser: {
      userName: '命主',
      gender: '乾造 (男)',
      birthDateStr: '1995-10-24',
      birthTimeStr: '14:30',
      isUnknownHour: false,
      cityIndex: 0
    },
    partnerUser: {
      userName: '對象',
      gender: '坤造 (女)',
      birthDateStr: '1997-05-15',
      birthTimeStr: '09:15',
      isUnknownHour: false,
      cityIndex: 0
    },
    activeTab: 'metis',
    activeDimension: '財富',
    timeline: {
      scope: 'natal',
      decadeIndex: 0,
      selectedYear: new Date().getFullYear(),
      selectedMonth: 1,
      selectedDay: 1
    },
    chart: null,
    partnerChart: null
  };

  // MARK: - DOM 元素獲取
  const elements = {
    // Top Bar
    headerTitle: document.getElementById('headerTitle'),
    userQuickInfo: document.getElementById('userQuickInfo'),
    btnOpenBirthModal: document.getElementById('btnOpenBirthModal'),
    btnOpenShareModal: document.getElementById('btnOpenShareModal'),

    // Tabs
    tabBtns: document.querySelectorAll('.tab-btn'),
    tabPanes: document.querySelectorAll('.tab-pane'),

    // Metis View
    metisHeadline: document.getElementById('metisHeadline'),
    metisSubheadline: document.getElementById('metisSubheadline'),
    radarContainer: document.getElementById('radarContainer'),
    powerCardGreen: document.getElementById('powerCardGreen'),
    powerCardPurple: document.getElementById('powerCardPurple'),
    powerCardOrange: document.getElementById('powerCardOrange'),
    dimPillsContainer: document.getElementById('dimPillsContainer'),
    dimDetailBox: document.getElementById('dimDetailBox'),
    metisOverviewText: document.getElementById('metisOverviewText'),
    metisActionAdvice: document.getElementById('metisActionAdvice'),
    metisVerdict: document.getElementById('metisVerdict'),

    // Classical Grid View
    astrolabeGrid: document.getElementById('astrolabeGrid'),

    // Timeline View
    scopeBtns: document.querySelectorAll('.scope-btn'),
    timelineSliderRow: document.getElementById('timelineSliderRow'),
    timelineSlider: document.getElementById('timelineSlider'),
    sliderLabel: document.getElementById('sliderLabel'),
    timelineYearSelect: document.getElementById('timelineYearSelect'),
    timelineMonthSelect: document.getElementById('timelineMonthSelect'),
    timelineDaySelect: document.getElementById('timelineDaySelect'),
    timelineFocusBadge: document.getElementById('timelineFocusBadge'),
    timelineHeadline: document.getElementById('timelineHeadline'),
    timelineOverview: document.getElementById('timelineOverview'),
    timelineOpportunities: document.getElementById('timelineOpportunities'),
    timelinePrecautions: document.getElementById('timelinePrecautions'),
    timelineFawnAdvice: document.getElementById('timelineFawnAdvice'),

    // Synastry View
    synastryNameA: document.getElementById('synastryNameA'),
    synastryDescA: document.getElementById('synastryDescA'),
    synastryNameB: document.getElementById('synastryNameB'),
    synastryDescB: document.getElementById('synastryDescB'),
    synastryScoreNum: document.getElementById('synastryScoreNum'),
    synastryRelBadge: document.getElementById('synastryRelBadge'),
    synastryHeadline: document.getElementById('synastryHeadline'),
    synastryChemistry: document.getElementById('synastryChemistry'),
    synastryBlessings: document.getElementById('synastryBlessings'),
    synastryFriction: document.getElementById('synastryFriction'),
    synastryFawnAdvice: document.getElementById('synastryFawnAdvice'),
    btnOpenPartnerModal: document.getElementById('btnOpenPartnerModal'),

    // Modals
    birthModal: document.getElementById('birthModal'),
    birthModalClose: document.getElementById('birthModalClose'),
    birthForm: document.getElementById('birthForm'),
    inputUserName: document.getElementById('inputUserName'),
    inputGender: document.getElementById('inputGender'),
    inputBirthDate: document.getElementById('inputBirthDate'),
    inputBirthTime: document.getElementById('inputBirthTime'),
    inputUnknownHour: document.getElementById('inputUnknownHour'),
    inputCity: document.getElementById('inputCity'),

    partnerModal: document.getElementById('partnerModal'),
    partnerModalClose: document.getElementById('partnerModalClose'),
    partnerForm: document.getElementById('partnerForm'),
    inputPartnerName: document.getElementById('inputPartnerName'),
    inputPartnerGender: document.getElementById('inputPartnerGender'),
    inputPartnerBirthDate: document.getElementById('inputPartnerBirthDate'),
    inputPartnerBirthTime: document.getElementById('inputPartnerBirthTime'),
    inputPartnerUnknownHour: document.getElementById('inputPartnerUnknownHour'),
    inputPartnerCity: document.getElementById('inputPartnerCity'),

    palaceModal: document.getElementById('palaceModal'),
    palaceModalClose: document.getElementById('palaceModalClose'),
    palaceModalTitle: document.getElementById('palaceModalTitle'),
    palaceModalBody: document.getElementById('palaceModalBody'),

    shareModal: document.getElementById('shareModal'),
    shareModalClose: document.getElementById('shareModalClose'),
    shareReportText: document.getElementById('shareReportText'),
    btnCopyReport: document.getElementById('btnCopyReport'),
    btnPrintReport: document.getElementById('btnPrintReport'),

    toastNotice: document.getElementById('toastNotice')
  };

  // MARK: - 初始化城市選單
  function initCitySelects() {
    const cities = ZiweiEngine.PRESET_CITIES;
    const opts = cities.map((c, i) => `<option value="${i}">${c.region} - ${c.name}</option>`).join('');
    if (elements.inputCity) elements.inputCity.innerHTML = opts;
    if (elements.inputPartnerCity) elements.inputPartnerCity.innerHTML = opts;
  }

  // MARK: - 排盤計算觸發 (Recalculate Chart)
  function recalculateChart(syncToSheets = false) {
    const [y, m, d] = state.currentUser.birthDateStr.split('-').map(Number);
    const [h, min] = state.currentUser.birthTimeStr.split(':').map(Number);
    const birthDate = new Date(y, m - 1, d, h || 0, min || 0);

    const city = ZiweiEngine.PRESET_CITIES[state.currentUser.cityIndex] || ZiweiEngine.PRESET_CITIES[0];

    state.chart = ZiweiEngine.generateChart({
      birthDate: birthDate,
      city: city,
      gender: state.currentUser.gender,
      userName: state.currentUser.userName || '命主',
      isUnknownHour: state.currentUser.isUnknownHour
    });

    // 計算合盤對象
    const [py, pm, pd] = state.partnerUser.birthDateStr.split('-').map(Number);
    const [ph, pmin] = state.partnerUser.birthTimeStr.split(':').map(Number);
    const pDate = new Date(py, pm - 1, pd, ph || 0, pmin || 0);
    const pCity = ZiweiEngine.PRESET_CITIES[state.partnerUser.cityIndex] || ZiweiEngine.PRESET_CITIES[0];

    state.partnerChart = ZiweiEngine.generateChart({
      birthDate: pDate,
      city: pCity,
      gender: state.partnerUser.gender,
      userName: state.partnerUser.userName || '對象',
      isUnknownHour: state.partnerUser.isUnknownHour
    });

    // 靜默雲端同步 (自動背景處理，不打擾使用者)
    if (syncToSheets) {
      ZiweiEngine.silentSyncChart(state.chart, birthDate, state.currentUser.isUnknownHour);
    }

    renderAllViews();
  }

  // MARK: - 渲染所有視圖 (Render Views)
  function renderAllViews() {
    renderQuickInfo();
    renderMetisView();
    renderClassicalGrid();
    renderTimelineFortune();
    renderSynastryView();
  }

  // 1. 渲染頂部快速摘要
  function renderQuickInfo() {
    const c = state.chart;
    if (!c) return;
    const hourText = c.isUnknownHour ? '子時 (時辰未知)' : `${c.lunarInfo.hourBranch}時`;
    elements.userQuickInfo.innerHTML = `
      <div>命主：<span class="user-badge">${c.userName}</span>（${c.gender}）</div>
      <div>農曆：<b>${c.lunarInfo.lunarDateString}</b></div>
      <div>八字：<b>${c.lunarInfo.baZiString}</b></div>
      <div>局數：<b>${c.elementBureau.name}</b></div>
      <div>命主：<b>${c.lifeMaster}</b> / 身主：<b>${c.bodyMaster}</b></div>
    `;
  }

  // 2. 渲染 Metis 現代白話解說
  function renderMetisView() {
    const c = state.chart;
    if (!c) return;
    const metis = ZiweiEngine.generateMetisReport(c);

    elements.metisHeadline.textContent = metis.headline;
    elements.metisSubheadline.textContent = metis.subHeadline;

    // 渲染雷達圖 SVG
    renderRadarChart(metis.scores);

    // 三大核心卡片
    elements.powerCardGreen.textContent = metis.coreAdvantage;
    elements.powerCardPurple.textContent = metis.relationshipPattern;
    elements.powerCardOrange.textContent = metis.growthChallenge;

    // 維度標籤列表
    const dims = ['財富', '事業', '感情', '性格', '健康', '人際貴人', '田宅', '父母長輩'];
    elements.dimPillsContainer.innerHTML = dims.map(d => `
      <button class="dim-pill ${d === state.activeDimension ? 'active' : ''}" data-dim="${d}">${d}</button>
    `).join('');

    // 維度詳細內容
    renderDimensionDetail(metis.dimensionDetails[state.activeDimension] || metis.dimensionDetails['財富']);

    // 長篇總結
    elements.metisOverviewText.textContent = metis.detailedOverview;
    elements.metisActionAdvice.textContent = metis.actionableAdvice;
    elements.metisVerdict.textContent = metis.oneSentenceVerdict;
  }

  function renderDimensionDetail(dt) {
    if (!dt) return;
    elements.dimDetailBox.innerHTML = `
      <div class="dim-header">
        <div>
          <h3 style="color:var(--ghibli-forest-moss);font-size:1.1rem;display:inline-block;margin-right:8px;">${dt.name}深度解讀</h3>
          <span style="font-size:0.85rem;color:var(--ghibli-text-muted);">坐鎮：${dt.palaceName} (${dt.palaceBranch}) - ${dt.majorStars}</span>
        </div>
        <div class="dim-score-badge">${dt.score}分・${dt.ratingText}</div>
      </div>
      <p style="font-size:0.92rem;margin-bottom:12px;color:var(--ghibli-text-main);">${dt.coreEssence}</p>
      
      <div style="margin-bottom:10px;">
        <h4 style="font-size:0.88rem;color:var(--ghibli-forest-moss);margin-bottom:4px;">🌟 天賦特質與優勢：</h4>
        <ul class="dim-list">${dt.advantages.map(a => `<li>${a}</li>`).join('')}</ul>
      </div>

      <div style="margin-bottom:10px;">
        <h4 style="font-size:0.88rem;color:var(--ghibli-calcifer-orange);margin-bottom:4px;">⚠️ 盲點防範提醒：</h4>
        <ul class="dim-list">${dt.blindSpots.map(b => `<li>${b}</li>`).join('')}</ul>
      </div>

      <div style="margin-bottom:10px;">
        <h4 style="font-size:0.88rem;color:var(--ghibli-lucky-blue);margin-bottom:4px;">🎯 落地破局策略：</h4>
        <ul class="dim-list">${dt.actionStrategies.map(s => `<li>${s}</li>`).join('')}</ul>
      </div>

      <div class="fawn-tip-bubble">
        <span>🦌</span>
        <div>${dt.fawnTips}</div>
      </div>
    `;
  }

  // 繪製六維雷達圖 SVG
  function renderRadarChart(scores) {
    const keys = [
      { key: 'personality', label: '性格特質' },
      { key: 'career', label: '事業突破' },
      { key: 'wealth', label: '財富累積' },
      { key: 'relationship', label: '感情共鳴' },
      { key: 'health', label: '健康元氣' },
      { key: 'overall', label: '綜合格局' }
    ];

    const size = 300;
    const center = size / 2;
    const radius = 105;
    const angleStep = (2 * Math.PI) / keys.length;

    // 網格環
    let gridLines = '';
    [0.25, 0.5, 0.75, 1.0].forEach(rRatio => {
      const r = radius * rRatio;
      const pts = keys.map((_, i) => {
        const a = i * angleStep - Math.PI / 2;
        return `${center + r * Math.cos(a)},${center + r * Math.sin(a)}`;
      }).join(' ');
      gridLines += `<polygon points="${pts}" fill="none" stroke="#CFBA9C" stroke-width="1" stroke-dasharray="${rRatio < 1 ? '3,3' : 'none'}"/>`;
    });

    // 軸線與標籤
    let axes = '';
    keys.forEach((k, i) => {
      const a = i * angleStep - Math.PI / 2;
      const x2 = center + radius * Math.cos(a);
      const y2 = center + radius * Math.sin(a);
      const lx = center + (radius + 22) * Math.cos(a);
      const ly = center + (radius + 22) * Math.sin(a);
      axes += `<line x1="${center}" y1="${center}" x2="${x2}" y2="${y2}" stroke="#CFBA9C" stroke-width="1"/>`;
      axes += `<text x="${lx}" y="${ly}" font-family="Noto Serif TC, serif" font-size="11" fill="#34523F" font-weight="600" text-anchor="middle" dominant-baseline="central">${k.label}</text>`;
    });

    // 數值多邊形
    const polyPts = keys.map((k, i) => {
      const val = Math.min(Math.max(scores[k.key] || 70, 0), 100);
      const r = (val / 100) * radius;
      const a = i * angleStep - Math.PI / 2;
      return `${center + r * Math.cos(a)},${center + r * Math.sin(a)}`;
    }).join(' ');

    const svg = `
      <svg viewBox="0 0 ${size} ${size}">
        ${gridLines}
        ${axes}
        <polygon points="${polyPts}" fill="rgba(217, 97, 56, 0.25)" stroke="#D96138" stroke-width="2.5" stroke-linejoin="round"/>
        ${keys.map((k, i) => {
          const val = Math.min(Math.max(scores[k.key] || 70, 0), 100);
          const r = (val / 100) * radius;
          const a = i * angleStep - Math.PI / 2;
          const px = center + r * Math.cos(a);
          const py = center + r * Math.sin(a);
          return `<circle cx="${px}" cy="${py}" r="4" fill="#C49B3C" stroke="#FAF6EE" stroke-width="1.5"/>`;
        }).join('')}
      </svg>
    `;

    elements.radarContainer.innerHTML = svg;
  }

  // 3. 渲染 4x4 天圓地方宮格 (Classical Grid)
  function renderClassicalGrid() {
    const c = state.chart;
    if (!c) return;

    // 4x4 座標對應宮位地支索引：
    // [0,0]=5(巳), [0,1]=6(午), [0,2]=7(未), [0,3]=8(申)
    // [1,0]=4(辰), [中宮 2x2],                 [1,3]=9(酉)
    // [2,0]=3(卯), [中宮 2x2],                 [2,3]=10(戌)
    // [3,0]=2(寅), [3,1]=1(丑), [3,2]=0(子), [3,3]=11(亥)

    const gridLayout = [
      5, 6, 7, 8,
      4, 'CENTER', 9,
      3, 10,
      2, 1, 0, 11
    ];

    let html = '';
    // Row 0
    [5, 6, 7, 8].forEach(b => html += renderPalaceCell(c.palaces[b]));
    // Row 1
    html += renderPalaceCell(c.palaces[4]);
    html += renderCenterPalace(c);
    html += renderPalaceCell(c.palaces[9]);
    // Row 2
    html += renderPalaceCell(c.palaces[3]);
    html += renderPalaceCell(c.palaces[10]);
    // Row 3
    [2, 1, 0, 11].forEach(b => html += renderPalaceCell(c.palaces[b]));

    elements.astrolabeGrid.innerHTML = html;

    // 綁定宮位點擊
    document.querySelectorAll('.palace-cell').forEach(cell => {
      cell.addEventListener('click', function () {
        const bIdx = parseInt(this.getAttribute('data-branch'));
        openPalaceDetail(c.palaces[bIdx]);
      });
    });
  }

  function renderPalaceCell(p) {
    if (!p) return '';
    const isLife = p.isLifePalace;
    const isBody = p.isBodyPalace;
    const highlighted = (p.branch === state.timeline.highlightedBranch);

    const majorStars = p.stars.filter(s => s.category === 'major');
    const luckyStars = p.stars.filter(s => s.category === 'lucky');
    const fierceStars = p.stars.filter(s => s.category === 'fierce');
    const auxStars = p.stars.filter(s => s.category === 'auxiliary');

    return `
      <div class="palace-cell ${isLife ? 'life-palace' : ''} ${highlighted ? 'highlighted-palace' : ''}" data-branch="${p.branchIndex}">
        <div class="palace-header">
          <span class="palace-name">${p.name}</span>
          <div>
            ${isLife ? '<span class="palace-tag">命宮</span>' : ''}
            ${isBody ? '<span class="palace-tag" style="background:var(--ghibli-laputa-sky);">身宮</span>' : ''}
          </div>
          <span class="palace-branch">${p.stem}${p.branch}</span>
        </div>

        <div class="palace-stars-area">
          ${majorStars.map(s => `
            <span class="star-badge major">
              ${s.name}
              ${s.brightness ? `<span class="star-brightness">${s.brightness}</span>` : ''}
              ${s.transformation ? `<span class="star-tf">化${s.transformation}</span>` : ''}
            </span>
          `).join('')}

          ${luckyStars.map(s => `<span class="star-badge lucky">${s.name}</span>`).join('')}
          ${fierceStars.map(s => `<span class="star-badge fierce">${s.name}</span>`).join('')}
          ${auxStars.map(s => `<span class="star-badge auxiliary">${s.name}</span>`).join('')}
        </div>

        <div class="palace-footer">
          <span>大限 ${p.decadeStartAge}-${p.decadeEndAge}</span>
          <span>${p.branch}位</span>
        </div>
      </div>
    `;
  }

  function renderCenterPalace(c) {
    return `
      <div class="center-palace">
        <div>
          <div class="center-title">🦌 小鹿兒紫微斗數・中宮星盤</div>
          <div class="center-grid-info">
            <div class="info-item"><span class="info-label">命主：</span><span class="info-val">${c.userName}（${c.gender}）</span></div>
            <div class="info-item"><span class="info-label">局數：</span><span class="info-val">${c.elementBureau.name}</span></div>
            <div class="info-item"><span class="info-label">命主星：</span><span class="info-val">${c.lifeMaster}</span></div>
            <div class="info-item"><span class="info-label">身主星：</span><span class="info-val">${c.bodyMaster}</span></div>
            <div class="info-item" style="grid-column:span 2;"><span class="info-label">農曆：</span><span class="info-val">${c.lunarInfo.lunarDateString}</span></div>
            <div class="info-item" style="grid-column:span 2;"><span class="info-label">四柱八字：</span><span class="info-val">${c.lunarInfo.baZiString}</span></div>
            <div class="info-item" style="grid-column:span 2;"><span class="info-label">真太陽時：</span><span class="info-val">${c.city.name} (${c.solarCorrection.summaryText})</span></div>
          </div>
        </div>

        <div class="center-patterns">
          <div style="font-weight:700;color:var(--ghibli-forest-moss);margin-bottom:3px;">🏛️ 倪海廈《天紀》經典格局：</div>
          ${c.patterns.length > 0 ? c.patterns.map(pat => `
            <div style="margin-bottom:3px;">
              <span class="pattern-badge">${pat.name}</span>
              <span style="font-size:0.72rem;color:var(--ghibli-text-muted);">${pat.desc}</span>
            </div>
          `).join('') : '<span style="color:var(--ghibli-text-light);">格局平正溫和，行運以穩健為上。</span>'}
        </div>
      </div>
    `;
  }

  // 4. 渲染流年運勢軌道 (Timeline Fortune)
  function renderTimelineFortune() {
    const c = state.chart;
    if (!c) return;

    const tf = ZiweiEngine.calculateTimelineFortune(c, state.timeline.scope, {
      decadeIndex: state.timeline.decadeIndex,
      selectedYear: state.timeline.selectedYear,
      selectedMonth: state.timeline.selectedMonth,
      selectedDay: state.timeline.selectedDay
    });

    state.timeline.highlightedBranch = tf.highlightedBranch;

    elements.timelineFocusBadge.textContent = tf.focusText;
    elements.timelineHeadline.textContent = tf.headline;
    elements.timelineOverview.textContent = tf.plainOverview;

    elements.timelineOpportunities.innerHTML = tf.opportunities.map(o => `<li>${o}</li>`).join('');
    elements.timelinePrecautions.innerHTML = tf.precautions.map(p => `<li>${p}</li>`).join('');
    elements.timelineFawnAdvice.textContent = tf.fawnAdvice;

    // 滑桿顯示
    if (state.timeline.scope === 'decade') {
      elements.timelineSliderRow.style.display = 'flex';
      const curPalace = c.palaces[state.timeline.decadeIndex] || c.palaces[0];
      elements.sliderLabel.textContent = `當前大限：${curPalace.decadeStartAge} - ${curPalace.decadeEndAge} 歲 (${curPalace.name})`;
    } else {
      elements.timelineSliderRow.style.display = 'none';
    }
  }

  // 5. 渲染雙人合盤 (Synastry View)
  function renderSynastryView() {
    if (!state.chart || !state.partnerChart) return;
    const syn = ZiweiEngine.analyzeSynastry(state.chart, state.partnerChart);

    elements.synastryNameA.textContent = state.chart.userName;
    elements.synastryDescA.textContent = `${state.chart.gender}・命宮坐鎮【${state.chart.palaces[state.chart.lifeBranchIndex].stars.filter(s => s.category === 'major').map(s => s.name).join('、') || '借對宮'}】`;

    elements.synastryNameB.textContent = state.partnerChart.userName;
    elements.synastryDescB.textContent = `${state.partnerChart.gender}・命宮坐鎮【${state.partnerChart.palaces[state.partnerChart.lifeBranchIndex].stars.filter(s => s.category === 'major').map(s => s.name).join('、') || '借對宮'}】`;

    elements.synastryScoreNum.textContent = syn.overallScore;
    elements.synastryRelBadge.textContent = syn.relationshipType;
    elements.synastryHeadline.textContent = syn.headline;
    elements.synastryChemistry.textContent = syn.starChemistry;

    elements.synastryBlessings.innerHTML = syn.mutualBlessings.map(b => `<li>${b}</li>`).join('');
    elements.synastryFriction.innerHTML = syn.frictionPoints.map(f => `<li>${f}</li>`).join('');
    elements.synastryFawnAdvice.textContent = syn.fawnAdvice;
  }

  // MARK: - 宮位詳情彈跳視窗 (Palace Modal)
  function openPalaceDetail(palace) {
    if (!palace) return;
    elements.palaceModalTitle.textContent = `【${palace.name}】(${palace.branch}宮) 深度星曜格局解密`;

    const majorStars = palace.stars.filter(s => s.category === 'major');
    const luckyStars = palace.stars.filter(s => s.category === 'lucky');
    const fierceStars = palace.stars.filter(s => s.category === 'fierce');
    const auxStars = palace.stars.filter(s => s.category === 'auxiliary');

    elements.palaceModalBody.innerHTML = `
      <div style="background:var(--ghibli-cloud-white);border:1px solid var(--ghibli-border-brass);border-radius:8px;padding:12px;margin-bottom:14px;">
        <div style="font-size:0.95rem;font-weight:700;color:var(--ghibli-forest-moss);margin-bottom:4px;">
          天干地支：${palace.stem}${palace.branch} ｜ 大限運勢歲數：${palace.decadeStartAge} - ${palace.decadeEndAge} 歲
        </div>
        <div style="font-size:0.85rem;color:var(--ghibli-text-muted);">
          ${palace.isLifePalace ? '🌟 本命核心命宮，掌管終身品格心性與大局方向。' : ''}
          ${palace.isBodyPalace ? '🌙 重要身宮坐鎮，掌管中年後行為作風與立身基石。' : ''}
        </div>
      </div>

      <div style="margin-bottom:12px;">
        <h4 style="font-size:0.9rem;color:var(--ghibli-forest-moss);margin-bottom:6px;">十四主星坐鎮：</h4>
        <div style="display:flex;gap:6px;flex-wrap:wrap;">
          ${majorStars.length > 0 ? majorStars.map(s => `
            <span class="star-badge major" style="padding:4px 8px;font-size:0.85rem;">
              ${s.name} ${s.brightness ? `[${s.brightness}]` : ''} ${s.transformation ? `化${s.transformation}` : ''}
            </span>
          `).join('') : '<span style="font-size:0.85rem;color:var(--ghibli-text-light);">本宮無正曜主星，借對宮星曜照會。</span>'}
        </div>
      </div>

      <div style="margin-bottom:12px;">
        <h4 style="font-size:0.9rem;color:var(--ghibli-forest-moss);margin-bottom:6px;">吉星、煞曜與雜曜：</h4>
        <div style="display:flex;gap:6px;flex-wrap:wrap;">
          ${luckyStars.map(s => `<span class="star-badge lucky">${s.name}</span>`).join('')}
          ${fierceStars.map(s => `<span class="star-badge fierce">${s.name}</span>`).join('')}
          ${auxStars.map(s => `<span class="star-badge auxiliary">${s.name}</span>`).join('')}
        </div>
      </div>

      <div class="fawn-tip-bubble" style="margin-top:16px;">
        <span>🦌</span>
        <div>小鹿兒提點：星曜如琴鍵，吉凶相生相剋。無論逢吉星或見煞曜，存正直之心，行精進之事，自能趨吉避凶！</div>
      </div>
    `;

    elements.palaceModal.classList.add('active');
  }

  // MARK: - Toast 提示訊息
  function showToast(msg) {
    elements.toastNotice.textContent = msg;
    elements.toastNotice.classList.add('show');
    setTimeout(() => {
      elements.toastNotice.classList.remove('show');
    }, 2800);
  }

  // MARK: - 事件監聽綁定 (Event Listeners)
  function setupEventListeners() {
    // 標籤頁切換
    elements.tabBtns.forEach(btn => {
      btn.addEventListener('click', function () {
        const tab = this.getAttribute('data-tab');
        state.activeTab = tab;
        elements.tabBtns.forEach(b => b.classList.remove('active'));
        elements.tabPanes.forEach(p => p.classList.remove('active'));

        this.classList.add('active');
        const targetPane = document.getElementById(`tab-${tab}`);
        if (targetPane) targetPane.classList.add('active');

        if (tab === 'grid') renderClassicalGrid();
      });
    });

    // Metis 維度 Pill 點擊
    elements.dimPillsContainer.addEventListener('click', function (e) {
      if (e.target.classList.contains('dim-pill')) {
        const dim = e.target.getAttribute('data-dim');
        state.activeDimension = dim;
        document.querySelectorAll('.dim-pill').forEach(p => p.classList.remove('active'));
        e.target.classList.add('active');
        const metis = ZiweiEngine.generateMetisReport(state.chart);
        renderDimensionDetail(metis.dimensionDetails[dim]);
      }
    });

    // 流年 Scope 按鈕切換
    elements.scopeBtns.forEach(btn => {
      btn.addEventListener('click', function () {
        elements.scopeBtns.forEach(b => b.classList.remove('active'));
        this.classList.add('active');
        state.timeline.scope = this.getAttribute('data-scope');
        renderTimelineFortune();
        renderClassicalGrid();
      });
    });

    // 大限滑桿
    if (elements.timelineSlider) {
      elements.timelineSlider.addEventListener('input', function () {
        state.timeline.decadeIndex = parseInt(this.value);
        renderTimelineFortune();
        renderClassicalGrid();
      });
    }

    // 流年年份選單
    if (elements.timelineYearSelect) {
      elements.timelineYearSelect.addEventListener('change', function () {
        state.timeline.selectedYear = parseInt(this.value);
        renderTimelineFortune();
        renderClassicalGrid();
      });
    }

    // 流月選單
    if (elements.timelineMonthSelect) {
      elements.timelineMonthSelect.addEventListener('change', function () {
        state.timeline.selectedMonth = parseInt(this.value);
        renderTimelineFortune();
        renderClassicalGrid();
      });
    }

    // 流日選單
    if (elements.timelineDaySelect) {
      elements.timelineDaySelect.addEventListener('change', function () {
        state.timeline.selectedDay = parseInt(this.value);
        renderTimelineFortune();
        renderClassicalGrid();
      });
    }

    // 排盤設定彈窗
    elements.btnOpenBirthModal.addEventListener('click', () => {
      elements.inputUserName.value = state.currentUser.userName;
      elements.inputGender.value = state.currentUser.gender;
      elements.inputBirthDate.value = state.currentUser.birthDateStr;
      elements.inputBirthTime.value = state.currentUser.birthTimeStr;
      elements.inputUnknownHour.checked = state.currentUser.isUnknownHour;
      elements.inputCity.value = state.currentUser.cityIndex;
      elements.birthModal.classList.add('active');
    });

    elements.birthModalClose.addEventListener('click', () => {
      elements.birthModal.classList.remove('active');
    });

    elements.birthForm.addEventListener('submit', (e) => {
      e.preventDefault();
      state.currentUser.userName = elements.inputUserName.value.trim() || '命主';
      state.currentUser.gender = elements.inputGender.value;
      state.currentUser.birthDateStr = elements.inputBirthDate.value;
      state.currentUser.birthTimeStr = elements.inputBirthTime.value;
      state.currentUser.isUnknownHour = elements.inputUnknownHour.checked;
      state.currentUser.cityIndex = parseInt(elements.inputCity.value) || 0;

      elements.birthModal.classList.remove('active');
      recalculateChart(true); // 觸發排盤並靜默同步 Google Sheets
      showToast('🌟 命盤已精準重新運算校準完成！');
    });

    // 合盤對象設定彈窗
    elements.btnOpenPartnerModal.addEventListener('click', () => {
      elements.inputPartnerName.value = state.partnerUser.userName;
      elements.inputPartnerGender.value = state.partnerUser.gender;
      elements.inputPartnerBirthDate.value = state.partnerUser.birthDateStr;
      elements.inputPartnerBirthTime.value = state.partnerUser.birthTimeStr;
      elements.inputPartnerUnknownHour.checked = state.partnerUser.isUnknownHour;
      elements.inputPartnerCity.value = state.partnerUser.cityIndex;
      elements.partnerModal.classList.add('active');
    });

    elements.partnerModalClose.addEventListener('click', () => {
      elements.partnerModal.classList.remove('active');
    });

    elements.partnerForm.addEventListener('submit', (e) => {
      e.preventDefault();
      state.partnerUser.userName = elements.inputPartnerName.value.trim() || '對象';
      state.partnerUser.gender = elements.inputPartnerGender.value;
      state.partnerUser.birthDateStr = elements.inputPartnerBirthDate.value;
      state.partnerUser.birthTimeStr = elements.inputPartnerBirthTime.value;
      state.partnerUser.isUnknownHour = elements.inputPartnerUnknownHour.checked;
      state.partnerUser.cityIndex = parseInt(elements.inputPartnerCity.value) || 0;

      elements.partnerModal.classList.remove('active');
      recalculateChart(false);
      showToast('💫 雙人合盤磁場已成功重新校驗！');
    });

    // 宮位詳情關閉
    elements.palaceModalClose.addEventListener('click', () => {
      elements.palaceModal.classList.remove('active');
    });

    // 分享報告彈窗
    elements.btnOpenShareModal.addEventListener('click', () => {
      const fullReport = ZiweiEngine.generateFullReport(state.chart);
      elements.shareReportText.value = fullReport;
      elements.shareModal.classList.add('active');
    });

    elements.shareModalClose.addEventListener('click', () => {
      elements.shareModal.classList.remove('active');
    });

    elements.btnCopyReport.addEventListener('click', () => {
      const fullReport = elements.shareReportText.value;
      navigator.clipboard.writeText(fullReport).then(() => {
        showToast('📋 已複製千字天命報告至剪貼簿，可直接貼上 LINE 分享！');
      }).catch(() => {
        elements.shareReportText.select();
        document.execCommand('copy');
        showToast('📋 已選取並複製報告至剪貼簿！');
      });
    });

    elements.btnPrintReport.addEventListener('click', () => {
      window.print();
    });

    // 點擊遮罩外側關閉彈窗
    window.addEventListener('click', (e) => {
      if (e.target.classList.contains('modal-overlay')) {
        e.target.classList.remove('active');
      }
    });
  }

  // MARK: - 啟動入口
  function init() {
    initCitySelects();
    setupEventListeners();
    recalculateChart(false);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

})();
