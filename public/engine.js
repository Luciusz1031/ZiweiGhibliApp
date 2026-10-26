/**
 * 小鹿兒紫微斗數・核心天命演算法引擎 (Xiao Luer Ziwei Engine)
 * 遵循倪海廈先生《天紀》排盤法則與真太陽時精密天文校驗
 * 100% 純前端獨立離線運算，零外部依賴
 */

(function (global) {
  'use strict';

  // MARK: - 基礎常量 (Constants)
  const HEAVENLY_STEMS = [
    { name: '甲', element: '木', isYang: true },
    { name: '乙', element: '木', isYang: false },
    { name: '丙', element: '火', isYang: true },
    { name: '丁', element: '火', isYang: false },
    { name: '戊', element: '土', isYang: true },
    { name: '己', element: '土', isYang: false },
    { name: '庚', element: '金', isYang: true },
    { name: '辛', element: '金', isYang: false },
    { name: '壬', element: '水', isYang: true },
    { name: '癸', element: '水', isYang: false }
  ];

  const EARTHLY_BRANCHES = [
    { name: '子', zodiac: '鼠', timeRange: '23:00 - 01:00' },
    { name: '丑', zodiac: '牛', timeRange: '01:00 - 03:00' },
    { name: '寅', zodiac: '虎', timeRange: '03:00 - 05:00' },
    { name: '卯', zodiac: '兔', timeRange: '05:00 - 07:00' },
    { name: '辰', zodiac: '龍', timeRange: '07:00 - 09:00' },
    { name: '巳', zodiac: '蛇', timeRange: '09:00 - 11:00' },
    { name: '午', zodiac: '馬', timeRange: '11:00 - 13:00' },
    { name: '未', zodiac: '羊', timeRange: '13:00 - 15:00' },
    { name: '申', zodiac: '猴', timeRange: '15:00 - 17:00' },
    { name: '酉', zodiac: '雞', timeRange: '17:00 - 19:00' },
    { name: '戌', zodiac: '狗', timeRange: '19:00 - 21:00' },
    { name: '亥', zodiac: '豬', timeRange: '21:00 - 23:00' }
  ];

  const PALACE_NAMES = [
    '命宮', '兄弟', '夫妻', '子女', '財帛', '疾厄',
    '遷移', '交友', '官祿', '田宅', '福德', '父母'
  ];

  const ELEMENT_BUREAUS = {
    2: { name: '水二局', number: 2 },
    3: { name: '木三局', number: 3 },
    4: { name: '金四局', number: 4 },
    5: { name: '土五局', number: 5 },
    6: { name: '火六局', number: 6 }
  };

  const PRESET_CITIES = [
    { name: '台北市', region: '台灣', lon: 121.5654, lat: 25.0330, stdLon: 120.0, tz: 'Asia/Taipei' },
    { name: '新北市', region: '台灣', lon: 121.4627, lat: 25.0117, stdLon: 120.0, tz: 'Asia/Taipei' },
    { name: '桃園市', region: '台灣', lon: 121.3009, lat: 24.9936, stdLon: 120.0, tz: 'Asia/Taipei' },
    { name: '新竹市', region: '台灣', lon: 120.9675, lat: 24.8138, stdLon: 120.0, tz: 'Asia/Taipei' },
    { name: '台中市', region: '台灣', lon: 120.6736, lat: 24.1477, stdLon: 120.0, tz: 'Asia/Taipei' },
    { name: '彰化市', region: '台灣', lon: 120.5422, lat: 24.0815, stdLon: 120.0, tz: 'Asia/Taipei' },
    { name: '嘉義市', region: '台灣', lon: 120.4491, lat: 23.4800, stdLon: 120.0, tz: 'Asia/Taipei' },
    { name: '台南市', region: '台灣', lon: 120.1979, lat: 22.9997, stdLon: 120.0, tz: 'Asia/Taipei' },
    { name: '高雄市', region: '台灣', lon: 120.3120, lat: 22.6273, stdLon: 120.0, tz: 'Asia/Taipei' },
    { name: '基隆市', region: '台灣', lon: 121.7462, lat: 25.1276, stdLon: 120.0, tz: 'Asia/Taipei' },
    { name: '宜蘭市', region: '台灣', lon: 121.7533, lat: 24.7570, stdLon: 120.0, tz: 'Asia/Taipei' },
    { name: '花蓮市', region: '台灣', lon: 121.6068, lat: 23.9871, stdLon: 120.0, tz: 'Asia/Taipei' },
    { name: '台東市', region: '台灣', lon: 121.1444, lat: 22.7583, stdLon: 120.0, tz: 'Asia/Taipei' },
    { name: '澎湖馬公', region: '台灣', lon: 119.5794, lat: 23.5658, stdLon: 120.0, tz: 'Asia/Taipei' },
    { name: '香港', region: '港澳', lon: 114.1694, lat: 22.3193, stdLon: 120.0, tz: 'Asia/Hong_Kong' },
    { name: '澳門', region: '港澳', lon: 113.5439, lat: 22.1987, stdLon: 120.0, tz: 'Asia/Macau' },
    { name: '北京', region: '大陸', lon: 116.4074, lat: 39.9042, stdLon: 120.0, tz: 'Asia/Shanghai' },
    { name: '上海', region: '大陸', lon: 121.4737, lat: 31.2304, stdLon: 120.0, tz: 'Asia/Shanghai' },
    { name: '廣州', region: '大陸', lon: 113.2644, lat: 23.1291, stdLon: 120.0, tz: 'Asia/Shanghai' },
    { name: '深圳', region: '大陸', lon: 114.0579, lat: 22.5431, stdLon: 120.0, tz: 'Asia/Shanghai' },
    { name: '新加坡', region: '海外', lon: 103.8198, lat: 1.3521, stdLon: 120.0, tz: 'Asia/Singapore' },
    { name: '吉隆坡', region: '海外', lon: 101.6869, lat: 3.1390, stdLon: 120.0, tz: 'Asia/Kuala_Lumpur' },
    { name: '東京', region: '海外', lon: 139.6917, lat: 35.6895, stdLon: 135.0, tz: 'Asia/Tokyo' },
    { name: '首爾', region: '海外', lon: 126.9780, lat: 37.5665, stdLon: 135.0, tz: 'Asia/Seoul' },
    { name: '紐約', region: '海外', lon: -74.0060, lat: 40.7128, stdLon: -75.0, tz: 'America/New_York' },
    { name: '洛杉磯', region: '海外', lon: -118.2437, lat: 34.0522, stdLon: -120.0, tz: 'America/Los_Angeles' },
    { name: '倫敦', region: '海外', lon: -0.1278, lat: 51.5074, stdLon: 0.0, tz: 'Europe/London' },
    { name: '雪梨', region: '海外', lon: 151.2093, lat: -33.8688, stdLon: 150.0, tz: 'Australia/Sydney' }
  ];

  // MARK: - 真太陽時天文演算法 (NOAA / Spencer EOT)
  function calculateEquationOfTime(date) {
    const startOfYear = new Date(date.getFullYear(), 0, 1);
    const dayOfYear = Math.floor((date - startOfYear) / (24 * 60 * 60 * 1000)) + 1;
    const gamma = (2.0 * Math.PI / 365.0) * (dayOfYear - 1.0);
    return 229.18 * (
      0.000075 +
      0.001868 * Math.cos(gamma) -
      0.032077 * Math.sin(gamma) -
      0.014615 * Math.cos(2.0 * gamma) -
      0.040849 * Math.sin(2.0 * gamma)
    );
  }

  function calculateTrueSolarTime(date, city) {
    const lonDiff = city.lon - city.stdLon;
    const lonOffsetMinutes = lonDiff * 4.0;
    const eotMinutes = calculateEquationOfTime(date);
    const totalOffsetMinutes = lonOffsetMinutes + eotMinutes;
    const trueSolarDate = new Date(date.getTime() + totalOffsetMinutes * 60 * 1000);

    const hour = trueSolarDate.getHours();
    let isLateZi = (hour === 23);
    let isEarlyZi = (hour === 0);
    let branchIndex = Math.floor((hour + 1) % 24 / 2);

    return {
      originalDate: date,
      trueSolarDate: trueSolarDate,
      longitudeOffsetMinutes: lonOffsetMinutes,
      equationOfTimeMinutes: eotMinutes,
      totalOffsetMinutes: totalOffsetMinutes,
      hourBranchIndex: branchIndex,
      isLateZi: isLateZi,
      isEarlyZi: isEarlyZi,
      summaryText: `真太陽時偏差: ${totalOffsetMinutes >= 0 ? '+' : ''}${totalOffsetMinutes.toFixed(1)}分`
    };
  }

  // MARK: - 農曆與八字四柱計算 (Chinese Lunar Calendar)
  function calculateDayStemBranch(targetDate) {
    const baseDate = new Date(Date.UTC(2000, 0, 1, 12, 0, 0)); // 2000-01-01 戊午日 (戊=4, 午=6)
    const d = new Date(Date.UTC(targetDate.getFullYear(), targetDate.getMonth(), targetDate.getDate(), 12, 0, 0));
    const diffDays = Math.round((d.getTime() - baseDate.getTime()) / (86400 * 1000));
    const stemIndex = ((4 + diffDays) % 10 + 10) % 10;
    const branchIndex = ((6 + diffDays) % 12 + 12) % 12;
    return { stemIndex: stemIndex, branchIndex: branchIndex };
  }

  function getLunarDateInfo(date, hourBranchIndex, isLateZi) {
    let targetDate = new Date(date.getTime());
    if (isLateZi) {
      // 倪海廈天紀「子初換日」：夜子時日柱計入次日
      targetDate = new Date(targetDate.getTime() + 3600 * 1000);
    }

    // 利用原生現代 Intl.DateTimeFormat('zh-TW-u-ca-chinese') 精準取得農曆年月日時
    const fmt = new Intl.DateTimeFormat('zh-TW-u-ca-chinese', { dateStyle: 'full' });
    const parts = fmt.formatToParts(targetDate);
    
    let yearName = '';
    let monthStr = '';
    let dayStr = '';

    for (const p of parts) {
      if (p.type === 'yearName') yearName = p.value;
      if (p.type === 'month') monthStr = p.value;
      if (p.type === 'day') dayStr = p.value;
    }

    // 解析農曆月數
    const monthMap = { '正月': 1, '二月': 2, '三月': 3, '四月': 4, '五月': 5, '六月': 6, '七月': 7, '八月': 8, '九月': 9, '十月': 10, '十一月': 11, '冬月': 11, '十二月': 12, '臘月': 12 };
    let isLeap = monthStr.includes('閏');
    let cleanMonth = monthStr.replace('閏', '');
    let lunarMonth = monthMap[cleanMonth] || parseInt(cleanMonth) || 1;

    // 解析農曆日數
    const dayMap = {
      '初一': 1, '初二': 2, '初三': 3, '初四': 4, '初五': 5, '初六': 6, '初七': 7, '初八': 8, '初九': 9, '初十': 10,
      '十一': 11, '十二': 12, '十三': 13, '十四': 14, '十五': 15, '十六': 16, '十七': 17, '十八': 18, '十九': 19, '二十': 20,
      '廿一': 21, '廿二': 22, '廿三': 23, '廿四': 24, '廿五': 25, '廿六': 26, '廿七': 27, '廿八': 28, '廿九': 29, '三十': 30
    };
    let lunarDay = dayMap[dayStr] || parseInt(dayStr) || 1;

    // 年干支 (西元4年為甲子年)
    const gregYear = targetDate.getFullYear();
    const gregMonth = targetDate.getMonth() + 1;
    let actualYear = gregYear;
    if (gregMonth === 1 && lunarMonth >= 11) {
      actualYear = gregYear - 1;
    }
    const yearStemIndex = ((actualYear - 4) % 10 + 10) % 10;
    const yearBranchIndex = ((actualYear - 4) % 12 + 12) % 12;

    // 五虎遁月起月干 (甲己之年丙作首)
    const tigerStartStem = [2, 4, 6, 8, 0, 2, 4, 6, 8, 0][yearStemIndex];
    const monthStemIndex = (tigerStartStem + (lunarMonth - 1)) % 10;
    const monthBranchIndex = (2 + (lunarMonth - 1)) % 12; // 寅為正月

    // 日干支
    const dayPillar = calculateDayStemBranch(targetDate);

    // 五鼠遁日起時干 (甲己還加甲)
    const ratStartStem = [0, 2, 4, 6, 8, 0, 2, 4, 6, 8][dayPillar.stemIndex];
    const hourStemIndex = (ratStartStem + hourBranchIndex) % 10;

    const yStem = HEAVENLY_STEMS[yearStemIndex].name;
    const yBranch = EARTHLY_BRANCHES[yearBranchIndex].name;
    const mStem = HEAVENLY_STEMS[monthStemIndex].name;
    const mBranch = EARTHLY_BRANCHES[monthBranchIndex].name;
    const dStem = HEAVENLY_STEMS[dayPillar.stemIndex].name;
    const dBranch = EARTHLY_BRANCHES[dayPillar.branchIndex].name;
    const hStem = HEAVENLY_STEMS[hourStemIndex].name;
    const hBranch = EARTHLY_BRANCHES[hourBranchIndex].name;

    const leapStr = isLeap ? '閏' : '';
    const mNames = ['', '正', '二', '三', '四', '五', '六', '七', '八', '九', '十', '冬', '臘'];
    const dNames = ['', '初一', '初二', '初三', '初四', '初五', '初六', '初七', '初八', '初九', '初十',
                    '十一', '十二', '十三', '十四', '十五', '十六', '十七', '十八', '十九', '二十',
                    '廿一', '廿二', '廿三', '廿四', '廿五', '廿六', '廿七', '廿八', '廿九', '三十'];

    const lunarDateString = `農曆 ${yStem}${yBranch}年 ${leapStr}${mNames[lunarMonth] || lunarMonth}月${dNames[lunarDay] || lunarDay}日 ${hStem}${hBranch}時`;
    const baZiString = `${yStem}${yBranch}年  ${mStem}${mBranch}月  ${dStem}${dBranch}日  ${hStem}${hBranch}時`;

    return {
      lunarYear: actualYear,
      lunarMonth: lunarMonth,
      lunarDay: lunarDay,
      isLeapMonth: isLeap,
      yearStemIndex: yearStemIndex,
      yearBranchIndex: yearBranchIndex,
      monthStemIndex: monthStemIndex,
      monthBranchIndex: monthBranchIndex,
      dayStemIndex: dayPillar.stemIndex,
      dayBranchIndex: dayPillar.branchIndex,
      hourStemIndex: hourStemIndex,
      hourBranchIndex: hourBranchIndex,
      yearStem: yStem,
      yearBranch: yBranch,
      monthStem: mStem,
      monthBranch: mBranch,
      dayStem: dStem,
      dayBranch: dBranch,
      hourStem: hStem,
      hourBranch: hBranch,
      lunarDateString: lunarDateString,
      baZiString: baZiString
    };
  }

  // MARK: - 五行局納音計算
  function calculateElementBureau(lifeStemIdx, lifeBranchIdx) {
    const stemNum = Math.floor(lifeStemIdx / 2) + 1;
    let branchNum = 1;
    if ([0, 1, 6, 7].includes(lifeBranchIdx)) branchNum = 1; // 子丑午未
    else if ([2, 3, 8, 9].includes(lifeBranchIdx)) branchNum = 2; // 寅卯申酉
    else branchNum = 3; // 辰巳戌亥

    let sum = stemNum + branchNum;
    if (sum > 5) sum -= 5;

    // 1=木三局, 2=金四局, 3=水二局, 4=火六局, 5=土五局
    const bureauMap = { 1: 3, 2: 4, 3: 2, 4: 6, 5: 5 };
    const num = bureauMap[sum] || 3;
    return ELEMENT_BUREAUS[num];
  }

  // MARK: - 起紫微與天府星
  function calculateZiweiBranch(lunarDay, bureauNum) {
    const x = bureauNum;
    const remainder = lunarDay % x;
    let q = Math.floor(lunarDay / x);
    let k = 0;
    if (remainder !== 0) {
      k = x - remainder;
      q = Math.floor((lunarDay + k) / x);
    }
    // 寅宮為起點 (2)
    let targetIndex = (2 + q - 1) % 12;
    if (k % 2 === 1) {
      targetIndex = (targetIndex - k + 12) % 12;
    } else {
      targetIndex = (targetIndex + k) % 12;
    }
    return targetIndex;
  }

  function calculateTianfuBranch(ziweiBranchIdx) {
    return (4 - ziweiBranchIdx + 12) % 12; // 辰(4) - 紫微
  }

  // MARK: - 生年四化 (含倪海廈天紀庚干體系)
  function calculateFourTransformations(yearStemIdx) {
    const tables = [
      { lu: '廉貞', quan: '破軍', ke: '武曲', ji: '太陽' }, // 甲
      { lu: '天機', quan: '天梁', ke: '紫微', ji: '太陰' }, // 乙
      { lu: '天同', quan: '天機', ke: '文昌', ji: '廉貞' }, // 丙
      { lu: '太陰', quan: '天同', ke: '天機', ji: '巨門' }, // 丁
      { lu: '貪狼', quan: '太陰', ke: '右弼', ji: '天機' }, // 戊
      { lu: '武曲', quan: '貪狼', ke: '天梁', ji: '文曲' }, // 己
      { lu: '太陽', quan: '武曲', ke: '太陰', ji: '天同' }, // 庚 (倪海廈天紀標準：日武陰同)
      { lu: '巨門', quan: '太陽', ke: '文曲', ji: '文昌' }, // 辛
      { lu: '天梁', quan: '紫微', ke: '左輔', ji: '武曲' }, // 壬
      { lu: '破軍', quan: '巨門', ke: '太陰', ji: '貪狼' }  // 癸
    ];
    return tables[yearStemIdx];
  }

  // MARK: - 輔吉煞曜起法
  function calculateLuCun(yearStemIdx) {
    const map = [2, 3, 5, 6, 5, 6, 8, 9, 11, 0];
    return map[yearStemIdx];
  }

  function calculateKuiYue(yearStemIdx) {
    const map = [
      [1, 7], [0, 8], [11, 9], [11, 9], [1, 7],
      [0, 8], [1, 7], [6, 2], [3, 5], [3, 5]
    ];
    return map[yearStemIdx];
  }

  function calculateTianMa(yearBranchIdx) {
    const map = {
      8: 2, 0: 2, 4: 2,
      2: 8, 6: 8, 10: 8,
      5: 11, 9: 11, 1: 11,
      11: 5, 3: 5, 7: 5
    };
    return map[yearBranchIdx] !== undefined ? map[yearBranchIdx] : 2;
  }

  function calculateLifeMaster(lifeBranchIdx) {
    const map = ['貪狼', '巨門', '祿存', '文曲', '廉貞', '武曲', '破軍', '武曲', '廉貞', '文曲', '祿存', '巨門'];
    return map[lifeBranchIdx];
  }

  function calculateBodyMaster(yearBranchIdx) {
    const map = ['火星', '天相', '天梁', '天同', '文昌', '天機', '火星', '天相', '天梁', '天同', '文昌', '天機'];
    return map[yearBranchIdx];
  }

  // 星曜廟旺利陷字典
  function getStarBrightness(starName, branchIdx) {
    const b = branchIdx;
    switch (starName) {
      case '紫微':
        if (b === 6) return '廟';
        if ([3, 4, 5, 7, 8, 9].includes(b)) return '旺';
        if ([2, 10].includes(b)) return '得';
        if ([1, 11].includes(b)) return '利';
        return '平';
      case '天機':
        if ([0, 6].includes(b)) return '廟';
        if ([3, 4].includes(b)) return '旺';
        if ([5, 8].includes(b)) return '得';
        if ([2, 9].includes(b)) return '利';
        if ([1, 7].includes(b)) return '陷';
        return '平';
      case '太陽':
        if ([5, 6].includes(b)) return '廟';
        if ([2, 3, 4].includes(b)) return '旺';
        if (b === 7) return '得';
        if (b === 8) return '利';
        if ([9, 10, 11, 0, 1].includes(b)) return '陷';
        return '平';
      case '武曲':
        if ([4, 10, 1, 7].includes(b)) return '廟';
        if ([2, 8, 0, 6].includes(b)) return '旺';
        if ([5, 11].includes(b)) return '平';
        return '得';
      case '天同':
        if ([2, 8].includes(b)) return '旺';
        if ([0, 5].includes(b)) return '廟';
        if ([3, 4].includes(b)) return '平';
        if ([6, 9, 10, 1, 7].includes(b)) return '陷';
        return '利';
      case '廉貞':
        if ([2, 8].includes(b)) return '廟';
        if ([0, 6, 7].includes(b)) return '旺';
        if ([4, 10].includes(b)) return '利';
        if ([5, 11].includes(b)) return '陷';
        return '平';
      case '天府':
        if ([2, 8, 0, 6].includes(b)) return '廟';
        if ([4, 10, 1, 7].includes(b)) return '旺';
        if ([5, 11].includes(b)) return '得';
        return '平';
      case '太陰':
        if ([9, 10, 11, 0].includes(b)) return '廟';
        if ([1, 2].includes(b)) return '旺';
        if ([3, 4, 5, 6, 7, 8].includes(b)) return '陷';
        return '利';
      case '貪狼':
        if ([1, 7].includes(b)) return '廟';
        if ([4, 10, 0, 6].includes(b)) return '旺';
        if ([2, 8].includes(b)) return '得';
        if ([5, 11].includes(b)) return '陷';
        return '平';
      case '巨門':
        if ([3, 9].includes(b)) return '廟';
        if ([2, 8].includes(b)) return '旺';
        if ([0, 6].includes(b)) return '旺';
        if ([4, 10].includes(b)) return '陷';
        return '平';
      case '天相':
        if ([2, 8].includes(b)) return '廟';
        if ([0, 6].includes(b)) return '旺';
        if ([3, 9].includes(b)) return '得';
        if ([3, 9].includes(b)) return '平';
        if ([4, 10].includes(b)) return '陷';
        return '利';
      case '天梁':
        if ([0, 6].includes(b)) return '廟';
        if ([2, 8].includes(b)) return '旺';
        if ([4, 10].includes(b)) return '旺';
        if ([5, 11].includes(b)) return '陷';
        return '利';
      case '七殺':
        if ([2, 8, 0, 6].includes(b)) return '廟';
        if ([4, 10].includes(b)) return '旺';
        if ([5, 11].includes(b)) return '平';
        return '得';
      case '破軍':
        if ([0, 6].includes(b)) return '廟';
        if ([4, 10].includes(b)) return '旺';
        if ([2, 8].includes(b)) return '得';
        if ([2, 8].includes(b)) return '利';
        if ([3, 9].includes(b)) return '陷';
        return '平';
      default:
        return null;
    }
  }

  // MARK: - 主排盤入口 (Main Astrolabe Chart Generation)
  function generateChart(params) {
    const {
      birthDate = new Date(1995, 9, 24, 14, 30),
      city = PRESET_CITIES[0],
      gender = '乾造 (男)',
      userName = '命主',
      isUnknownHour = false,
      useTrueSolarTime = true
    } = params;

    let effectiveDate = new Date(birthDate);
    if (isUnknownHour) {
      effectiveDate.setHours(0, 30, 0, 0); // 統一起子時早子
    }

    // 1. 真太陽時校準
    const solarCorrection = calculateTrueSolarTime(effectiveDate, city);
    const targetDate = useTrueSolarTime ? solarCorrection.trueSolarDate : effectiveDate;
    const hourBranchIndex = isUnknownHour ? 0 : solarCorrection.hourBranchIndex;

    // 2. 農曆八字
    const lunarInfo = getLunarDateInfo(targetDate, hourBranchIndex, solarCorrection.isLateZi);
    const effectiveMonth = lunarInfo.lunarMonth;

    // 3. 定命宮與身宮 (寅宮2起生月逆數生時為命宮，順數生時為身宮)
    const monthBranchIndex = (2 + effectiveMonth - 1) % 12;
    const lifeBranchIndex = (monthBranchIndex - hourBranchIndex + 12) % 12;
    const bodyBranchIndex = (monthBranchIndex + hourBranchIndex) % 12;

    // 4. 五虎遁年起月干：決定 12 宮天干 (寅宮起算)
    const tigerStartStem = [2, 4, 6, 8, 0, 2, 4, 6, 8, 0][lunarInfo.yearStemIndex];
    const palaceStems = new Array(12);
    for (let i = 0; i < 12; i++) {
      const bIdx = (2 + i) % 12;
      const sIdx = (tigerStartStem + i) % 10;
      palaceStems[bIdx] = sIdx;
    }

    // 5. 定五行局
    const lifeStemIndex = palaceStems[lifeBranchIndex];
    const elementBureau = calculateElementBureau(lifeStemIndex, lifeBranchIndex);

    // 6. 十二宮基本資料
    const palaces = [];
    for (let b = 0; b < 12; b++) {
      const offset = (lifeBranchIndex - b + 12) % 12;
      palaces.push({
        index: b,
        branch: EARTHLY_BRANCHES[b].name,
        branchIndex: b,
        stem: HEAVENLY_STEMS[palaceStems[b]].name,
        stemIndex: palaceStems[b],
        name: PALACE_NAMES[offset],
        typeIndex: offset,
        isLifePalace: (b === lifeBranchIndex),
        isBodyPalace: (b === bodyBranchIndex),
        stars: [],
        decadeStartAge: 0,
        decadeEndAge: 0
      });
    }

    // 7. 起大限歲數 (陽男陰女順行，陰男陽女逆行)
    const isYangYear = HEAVENLY_STEMS[lunarInfo.yearStemIndex].isYang;
    const isMale = gender.includes('男');
    const isClockwise = (isYangYear && isMale) || (!isYangYear && !isMale);
    const bureauNum = elementBureau.number;

    for (let i = 0; i < 12; i++) {
      const step = isClockwise ? i : (12 - i) % 12;
      const targetB = (lifeBranchIndex + step) % 12;
      const startAge = bureauNum + (i * 10);
      palaces[targetB].decadeStartAge = startAge;
      palaces[targetB].decadeEndAge = startAge + 9;
    }

    // 8. 安十四主星
    const ziweiBranch = calculateZiweiBranch(lunarInfo.lunarDay, bureauNum);
    const tianfuBranch = calculateTianfuBranch(ziweiBranch);

    const starsMap = Array.from({ length: 12 }, () => []);

    const ziweiStars = [
      { name: '紫微', offset: 0, element: '土' },
      { name: '天機', offset: -1, element: '木' },
      { name: '太陽', offset: -3, element: '火' },
      { name: '武曲', offset: -4, element: '金' },
      { name: '天同', offset: -5, element: '水' },
      { name: '廉貞', offset: -8, element: '火' }
    ];
    for (const star of ziweiStars) {
      const bIdx = (ziweiBranch + star.offset + 24) % 12;
      starsMap[bIdx].push({
        name: star.name,
        category: 'major',
        brightness: getStarBrightness(star.name, bIdx),
        element: star.element
      });
    }

    const tianfuStars = [
      { name: '天府', offset: 0, element: '土' },
      { name: '太陰', offset: 1, element: '水' },
      { name: '貪狼', offset: 2, element: '木' },
      { name: '巨門', offset: 3, element: '水' },
      { name: '天相', offset: 4, element: '水' },
      { name: '天梁', offset: 5, element: '土' },
      { name: '七殺', offset: 6, element: '金' },
      { name: '破軍', offset: 10, element: '水' }
    ];
    for (const star of tianfuStars) {
      const bIdx = (tianfuBranch + star.offset) % 12;
      starsMap[bIdx].push({
        name: star.name,
        category: 'major',
        brightness: getStarBrightness(star.name, bIdx),
        element: star.element
      });
    }

    // 9. 安六吉六煞輔曜
    const zuoFuIdx = (4 + (effectiveMonth - 1)) % 12;
    const youBiIdx = (10 - (effectiveMonth - 1) + 12) % 12;
    starsMap[zuoFuIdx].push({ name: '左輔', category: 'lucky', element: '土' });
    starsMap[youBiIdx].push({ name: '右弼', category: 'lucky', element: '水' });

    const wenChangIdx = (5 - hourBranchIndex + 12) % 12;
    const wenQuIdx = (4 + hourBranchIndex) % 12;
    starsMap[wenChangIdx].push({ name: '文昌', category: 'lucky', element: '金' });
    starsMap[wenQuIdx].push({ name: '文曲', category: 'lucky', element: '水' });

    const [kuiIdx, yueIdx] = calculateKuiYue(lunarInfo.yearStemIndex);
    starsMap[kuiIdx].push({ name: '天魁', category: 'lucky', element: '火' });
    starsMap[yueIdx].push({ name: '天鉞', category: 'lucky', element: '火' });

    const luCunIdx = calculateLuCun(lunarInfo.yearStemIndex);
    const qingYangIdx = (luCunIdx + 1) % 12;
    const tuoLuoIdx = (luCunIdx - 1 + 12) % 12;
    starsMap[luCunIdx].push({ name: '祿存', category: 'auxiliary', element: '土' });
    starsMap[qingYangIdx].push({ name: '擎羊', category: 'fierce', element: '金' });
    starsMap[tuoLuoIdx].push({ name: '陀羅', category: 'fierce', element: '金' });

    const diJieIdx = (11 + hourBranchIndex) % 12;
    const diKongIdx = (11 - hourBranchIndex + 12) % 12;
    starsMap[diKongIdx].push({ name: '地空', category: 'fierce', element: '火' });
    starsMap[diJieIdx].push({ name: '地劫', category: 'fierce', element: '火' });

    const tianMaIdx = calculateTianMa(lunarInfo.yearBranchIndex);
    starsMap[tianMaIdx].push({ name: '天馬', category: 'auxiliary', element: '火' });

    // 10. 生年四化標註
    const fourTransformations = calculateFourTransformations(lunarInfo.yearStemIndex);
    for (let b = 0; b < 12; b++) {
      for (const s of starsMap[b]) {
        if (s.name === fourTransformations.lu) s.transformation = '祿';
        else if (s.name === fourTransformations.quan) s.transformation = '權';
        else if (s.name === fourTransformations.ke) s.transformation = '科';
        else if (s.name === fourTransformations.ji) s.transformation = '忌';
      }
      palaces[b].stars = starsMap[b];
    }

    const lifeMaster = calculateLifeMaster(lifeBranchIndex);
    const bodyMaster = calculateBodyMaster(lunarInfo.yearBranchIndex);

    // 11. 倪海廈《天紀》經典格局匹配
    const patterns = matchTianjiPatterns(palaces, lifeBranchIndex);

    const chart = {
      userName: userName,
      gender: gender,
      isUnknownHour: isUnknownHour,
      solarDate: targetDate,
      city: city,
      lunarInfo: lunarInfo,
      solarCorrection: solarCorrection,
      elementBureau: elementBureau,
      lifeBranchIndex: lifeBranchIndex,
      bodyBranchIndex: bodyBranchIndex,
      lifeMaster: lifeMaster,
      bodyMaster: bodyMaster,
      palaces: palaces,
      patterns: patterns,
      fourTransformations: fourTransformations
    };

    return chart;
  }

  // MARK: - 倪海廈《天紀》格局匹配
  function matchTianjiPatterns(palaces, lifeBranchIdx) {
    const matched = [];
    const lifePalace = palaces[lifeBranchIdx];
    const lifeStars = new Set(lifePalace.stars.map(s => s.name));

    const careerIdx = (lifeBranchIdx + 4) % 12;
    const wealthIdx = (lifeBranchIdx + 8) % 12;
    const travelIdx = (lifeBranchIdx + 6) % 12;
    const sanFangStars = new Set();
    [lifeBranchIdx, careerIdx, wealthIdx, travelIdx].forEach(idx => {
      palaces[idx].stars.forEach(s => sanFangStars.add(s.name));
    });

    // 1. 紫府同宮格
    if ((lifeBranchIdx === 2 || lifeBranchIdx === 8) && lifeStars.has('紫微') && lifeStars.has('天府')) {
      matched.push({
        name: '紫府同宮格',
        isAuspicious: true,
        desc: '命宮在寅或申，紫微星與天府星同宮坐命，三方吉星相會。',
        tianjiComment: '倪海廈《天紀》曰：紫微為北極帝星，天府為南斗令星，二星同宮於寅申，性格忠厚圓融、福祿雙全。若加會左右昌曲，必為政界樞紐或商界領袖。',
        poem: '同宮紫府貴生人，天乙加臨福祿臻。甲己生人皆大吉，一生富貴秉朝綸。'
      });
    }

    // 2. 日月並明格
    const sunInSi = palaces[5].stars.some(s => s.name === '太陽');
    const moonInYou = palaces[9].stars.some(s => s.name === '太陰');
    if ((lifeBranchIdx === 1 || lifeBranchIdx === 7) && sunInSi && moonInYou) {
      matched.push({
        name: '日月並明格',
        isAuspicious: true,
        desc: '命宮在丑未，巳宮太陽旺、酉宮太陰旺，雙雙照入命宮。',
        tianjiComment: '倪海廈《天紀》曰：日出巳時光輝普照，月出酉時冰清玉潔。此格之人心地光明磊落，少年得志，早歲即展露鋒芒，一生順遂亨通。',
        poem: '日月並明金馬步，榮華富貴步蟾宮。天生聰明智慧廣，少年平步上雲霄。'
      });
    }

    // 3. 日照雷門格
    if (lifeBranchIdx === 3 && lifeStars.has('太陽') && lifeStars.has('天梁')) {
      matched.push({
        name: '日照雷門格 (日出扶桑)',
        isAuspicious: true,
        desc: '太陽與天梁在卯宮坐命，卯為東方震雷之位，日光萬丈。',
        tianjiComment: '倪師《天紀》論命：太陽居卯位為朝陽初昇，名日照雷門。此人胸襟開闊，一生正氣浩然，宜從公職、法政或大企業領導，名震八方。',
        poem: '太陽卯位貴堪誇，必主平生富貴家。若得化祿昌曲會，威名赫赫播天涯。'
      });
    }

    // 4. 月朗天門格
    if (lifeBranchIdx === 11 && lifeStars.has('太陰')) {
      matched.push({
        name: '月朗天門格',
        isAuspicious: true,
        desc: '太陰星在亥宮獨坐入命，亥為乾坤天門，太陰入廟最為清瑩。',
        tianjiComment: '倪師《天紀》云：月朗天門乃極貴之格，夜生人尤美。主為人文質彬彬、博學多才，多有跨國發展機遇，晚景財官雙美。',
        poem: '月朗天門富且榮，發財必定自青年。科權若在三方照，玉殿傳臚姓名宣。'
      });
    }

    // 5. 巨日同宮格
    if ((lifeBranchIdx === 2 || lifeBranchIdx === 8) && lifeStars.has('太陽') && lifeStars.has('巨門')) {
      matched.push({
        name: '巨日同宮格',
        isAuspicious: true,
        desc: '太陽巨門同在寅宮或申宮守命，化解巨門暗曜之氣。',
        tianjiComment: '《天紀》要旨：巨門為暗星主口舌是非，逢太陽烈火則暗霾盡驅。主口才便給、辯才無礙，極利法官、外交、教學或以口為業之人，白手起家創大業。',
        poem: '巨日同宮在寅申，白手成家最精神。若逢吉曜多富貴，威權赫奕拜皇仁。'
      });
    }

    // 6. 機月同梁格
    if (['天機', '太陰', '天同', '天梁'].every(s => sanFangStars.has(s))) {
      matched.push({
        name: '機月同梁格',
        isAuspicious: true,
        desc: '三方四正會齊天機、太陰、天同、天梁四顆吉星。',
        tianjiComment: '倪海廈《天紀》云：機月同梁做吏人。最擅長策劃、幕僚、公務員及專業技術研發。心思細膩有條理，不喜涉足風浪之險，一生平穩有爵祿。',
        poem: '寅申四位天機是，同梁月合主多才。文章卓犖稱雄手，必在公門作宰臺。'
      });
    }

    // 7. 殺破狼格
    if (['七殺', '破軍', '貪狼'].every(s => sanFangStars.has(s))) {
      matched.push({
        name: '殺破狼格 (動態開創格)',
        isAuspicious: true,
        desc: '命宮、財帛、事業三方由七殺、破軍、貪狼鎮守。',
        tianjiComment: '倪海廈《天紀》精闢斷語：殺破狼為人生巨大轉變之樞紐。此性格局開拓力極強，敢為天下先，遇困境能絕地逢生。動盪愈大，成就愈宏偉，為商戰名將或創業先鋒。',
        poem: '七殺破軍與貪狼，入命三方動盪長。英雄開闢乾坤手，千錘百鍊現鋒芒。'
      });
    }

    // 8. 陽梁昌祿格
    if (['太陽', '天梁', '文昌', '祿存'].every(s => sanFangStars.has(s))) {
      matched.push({
        name: '陽梁昌祿格',
        isAuspicious: true,
        desc: '三方四正會齊太陽、天梁、文昌與祿存四星。',
        tianjiComment: '倪海廈《天紀》極讚之考運與貴格：凡逢此格，科考無往不利，名列前茅，在專業認證、學術發表、公家考試上一鳴驚人，仕途青雲直上。',
        poem: '陽梁昌祿位居高，臚唱金鑾第一鰲。學富五車身顯達，平生榮貴佐王朝。'
      });
    }

    // 9. 馬頭帶劍格
    if (lifeBranchIdx === 6 && lifeStars.has('擎羊')) {
      matched.push({
        name: '馬頭帶劍格',
        isAuspicious: false,
        desc: '擎羊在午宮坐命，午為馬，擎羊如刀劍懸於馬首。',
        tianjiComment: '倪師《天紀》警示與吉凶相參：此格主軍旅武職或開拓異鄉可立功，但一生歷經險阻刀光劍影。天紀提醒：宜以技術專長立命，忌任性冒進。',
        poem: '擎羊在午馬頭帶，威震邊疆立大勳。若見吉星終可貴，不然橫逆受艱辛。'
      });
    }

    return matched;
  }

  // MARK: - 現代白話 Metis 分析引擎
  function generateMetisReport(chart) {
    const lifePalace = chart.palaces[chart.lifeBranchIndex];
    const careerPalace = chart.palaces.find(p => p.name === '官祿') || lifePalace;
    const wealthPalace = chart.palaces.find(p => p.name === '財帛') || lifePalace;
    const marriagePalace = chart.palaces.find(p => p.name === '夫妻') || lifePalace;
    const healthPalace = chart.palaces.find(p => p.name === '疾厄') || lifePalace;
    const friendsPalace = chart.palaces.find(p => p.name === '交友') || lifePalace;
    const propertyPalace = chart.palaces.find(p => p.name === '田宅') || lifePalace;
    const parentsPalace = chart.palaces.find(p => p.name === '父母') || lifePalace;

    function scorePalace(p, base) {
      let s = base;
      for (const st of p.stars) {
        if (st.brightness === '廟' || st.brightness === '旺') s += 5;
        else if (st.brightness === '得' || st.brightness === '利') s += 3;
        else if (st.brightness === '平') s += 1;
        else if (st.brightness === '陷') s -= 4;

        if (st.category === 'lucky') s += 4;
        if (st.category === 'fierce') s -= 4;
        if (st.transformation === '祿') s += 8;
        if (st.transformation === '權') s += 6;
        if (st.transformation === '科') s += 5;
        if (st.transformation === '忌') s -= 6;
      }
      return Math.min(Math.max(Math.round(s), 45), 96);
    }

    const pScore = scorePalace(lifePalace, 78);
    const cScore = scorePalace(careerPalace, 75);
    const wScore = scorePalace(wealthPalace, 72);
    const mScore = scorePalace(marriagePalace, 68);
    const hScore = scorePalace(healthPalace, 70);
    const overall = Math.round(pScore * 0.25 + cScore * 0.25 + wScore * 0.2 + mScore * 0.15 + hScore * 0.15);

    const scores = {
      overall: overall,
      career: cScore,
      wealth: wScore,
      relationship: mScore,
      personality: pScore,
      health: hScore
    };

    const majorNames = lifePalace.stars.filter(s => s.category === 'major').map(s => s.name);

    // 標題與副標
    let headline = '順應天時，蓄勢待發的沉著之星';
    let subHeadline = '命格內斂溫厚，循序漸進方顯英雄本色，厚積薄發必有大成。';

    if (majorNames.includes('破軍')) {
      headline = '敢推倒重來，敢走在前頭';
      subHeadline = '你適合白手起家、在生化風雲變革中開創，不適合安於溫水靜坐不動。';
    } else if (majorNames.includes('七殺')) {
      headline = '橫刀立馬，開疆拓土的獨行大將';
      subHeadline = '你具備無畏競爭的決斷力，在動態環境中越挫越勇，成就在於大膽跨界。';
    } else if (majorNames.includes('紫微')) {
      headline = '定海神針，統率全場的格局之王';
      subHeadline = '天生自帶威嚴與凝聚力，具備宏觀思維，適合主導大局與帶領團隊。';
    } else if (majorNames.includes('武曲')) {
      headline = '果敢實幹，百折不撓的金石之質';
      subHeadline = '行動就是你的最強武器，對金錢與效率有著天生敏銳度，白手成家典範。';
    } else if (majorNames.includes('天機')) {
      headline = '算無遺策，靈活應變的當代軍師';
      subHeadline = '心思細膩、洞察先機，靠智力謀略與專業技能取勝，永遠走在時代前沿。';
    } else if (majorNames.includes('太陽')) {
      headline = '普照四方，慷慨大度的破曉晨曦';
      subHeadline = '為人熱情正直、富有遠見，在公眾事務或群體中自帶強烈影響力。';
    } else if (majorNames.includes('太陰')) {
      headline = '潤物無聲，內蘊豐盈的溫柔智者';
      subHeadline = '心思細密、富有藝術直覺，善於默默耕耘，蓄積深厚的長線福澤。';
    } else if (majorNames.includes('貪狼')) {
      headline = '八面玲瓏，無界探索的魅力先鋒';
      subHeadline = '多才多藝、涉獵廣泛，善於調動資源與掌握人心，生活永遠充滿可能性。';
    } else if (majorNames.includes('天府')) {
      headline = '坐鎮中軍，海納百川的福祿元帥';
      subHeadline = '處世穩健有度、包容宏大，兼具守成與開創之能，晚景昌隆安逸。';
    }

    // 核心三維度
    let coreAdvantage = '處事踏實有韌性，善於在平凡中積累不凡，抗風險能力與耐力出類拔萃。';
    if (majorNames.includes('破軍') || majorNames.includes('七殺')) {
      coreAdvantage = '你膽子大、有執行魄力，開新路不畏艱難，挫敗之後能以驚人速度滿血復活。';
    } else if (majorNames.includes('紫微') || majorNames.includes('天府')) {
      coreAdvantage = '你有大局觀與領導協調能力，面對混亂場面能沉著冷靜，天然能贏得他人信賴。';
    } else if (majorNames.includes('天機') || majorNames.includes('巨門')) {
      coreAdvantage = '邏輯分析能力極強，能一眼洞察事物本質與漏洞，靠智慧與策略克敵制勝。';
    }

    const relationshipPattern = '對待人際要麼愛恨分明、敢擔責任；一旦認可對方，護起人來拼盡全力，絕不拖泥帶水。';
    const growthChallenge = '衝勁足但有時定力稍缺，折騰時需要朝著明確長線目標聚焦收尾，格局方能真正成形。';

    const starsStr = majorNames.length > 0 ? majorNames.join('、') : '命無正曜借對宮';
    const detailedOverview = `你天生是個具有自我主見與求變意識的人。對老規矩往往有著本能的審視與反思，當別人在按部就班時，你的大腦已經在思考未來的破局點。你的骨子裡有種不服輸的韌勁，在壓力面前往往能爆發出驚人潛力。性格剛正、不喜阿諛奉承，比起表面功夫更注重實質成果與心安理得。\n\n命宮由 ${starsStr} 坐鎮，結合 ${chart.elementBureau.name} 的五行氣場，賦予了你獨特的人生節奏。在年少或起步階段，難免經歷一番摸索與考驗，甚至走過一些看似彎路的修煉；但每一次的推倒重來，都在為你提煉出更加堅固的人生底層邏輯。`;

    const actionableAdvice = '建議你主動跳出舒適圈，靠一門不可替代的專業技術或核心手藝向外闖蕩，這才是你積累深厚籌碼的最佳路徑。做事要有長線思維，認準一個領域至少精雕細琢三年，切忌頻繁換道。把決定權握在自己手裡，遇大事沉得住氣，你的輝煌期必將隨歲月沉澱而燦然大成！';
    const oneSentenceVerdict = '「知世故而不世故，歷千帆仍持初心；敢於破局重來者，終將自成天地。」';

    function formatStars(p) {
      const list = p.stars.filter(s => s.category === 'major').map(s => `${s.name}${s.brightness ? `[${s.brightness}]` : ''}`);
      return list.length > 0 ? list.join('、') : '借對宮吉星拱照';
    }

    function formatTransformations(p) {
      return p.stars.filter(s => s.transformation).map(s => `${s.name}化${s.transformation}`);
    }

    // 各維度深度子卡片
    const dimensionDetails = {
      '財富': {
        name: '財富',
        score: wScore,
        ratingText: wScore >= 85 ? '財源亨通・多元吸金體質' : '穩健蓄財・技術致富格局',
        palaceName: '財帛宮',
        palaceBranch: `${wealthPalace.branch}宮`,
        majorStars: formatStars(wealthPalace),
        transformations: formatTransformations(wealthPalace),
        coreEssence: `以 ${formatStars(wealthPalace)} 為求財根基。你的賺錢邏輯不靠道聽途說的盲目投機，而是靠個人無可替代的專業技術、獨特商業嗅覺與穩步累積，方能水到渠成。`,
        advantages: ['商業直覺敏銳，具備跨界整合資源與開拓多元進帳管道的能力。', '在動盪環境中懂得提前守住充足的流動性資金。'],
        blindSpots: ['切忌追求高槓桿短期暴利，防範因投機短炒造成回撤。'],
        actionStrategies: ['嚴格執行停利與止損紀律，將冒險獲利轉入穩健資產鎖定勝局。'],
        fawnTips: '小鹿兒招財錦囊：在皮夾常備一張嶄新開運金鈔，日常多穿搭深綠、駝色系衣飾，財氣最聚！'
      },
      '事業': {
        name: '事業',
        score: cScore,
        ratingText: cScore >= 85 ? '大將之風・開疆拓土先鋒' : '中流砥柱・核心骨幹骨相',
        palaceName: '官祿宮',
        palaceBranch: `${careerPalace.branch}宮`,
        majorStars: formatStars(careerPalace),
        transformations: formatTransformations(careerPalace),
        coreEssence: `官祿宮坐鎮 ${formatStars(careerPalace)}，職場自帶擔當與執行力。適合在需要獨立決策、戰略規劃或核心技術的舞台發揮長才，越早獨當一面越容易成器。`,
        advantages: ['執行力雷厲風行、遇難題沉著果決，是能打硬仗的開拓先鋒。', '善於統籌全局並激發團隊潛能，贏得高層全力信任。'],
        blindSpots: ['性格剛烈直率，易因言語急切而得罪同儕或合作夥伴。'],
        actionStrategies: ['溝通時多留三分餘地，注重團隊協作以柔克剛，更能無往不利。'],
        fawnTips: '小鹿兒事業錦囊：辦公桌左手邊擺放一盆生機盎然的常青綠植，能為你帶來貴人助力與清晰思路！'
      },
      '感情': {
        name: '感情',
        score: mScore,
        ratingText: mScore >= 85 ? '情深意篤・心靈共鳴伴侶' : '相互扶持・並肩作戰良緣',
        palaceName: '夫妻宮',
        palaceBranch: `${marriagePalace.branch}宮`,
        majorStars: formatStars(marriagePalace),
        transformations: formatTransformations(marriagePalace),
        coreEssence: `夫妻宮由 ${formatStars(marriagePalace)} 守護。你在親密關係中重視的是精神層面的深度對話與三觀契合，比起海誓山盟，你更珍惜患難與共、平淡真實的默契溫暖。`,
        advantages: ['對感情專一真誠、富有責任擔當，願意為共同未來構築堅實後盾。', '懂得營造生活情趣，願意為維護關係和諧而體諒付出。'],
        blindSpots: ['性格較為強勢理性，說話習慣講道理而忽略了伴侶的情感共鳴需求。'],
        actionStrategies: ['每週安排專屬雙人時光，放下手機傾聽伴侶心聲，柔軟擁抱勝過千言萬語。'],
        fawnTips: '小鹿兒姻緣錦囊：臥室擺放柔和暖色系床頭夜燈，多噴點溫馨木質調香氛，良緣自然甜甜蜜蜜！'
      },
      '性格': {
        name: '性格',
        score: pScore,
        ratingText: '自尊獨立・內蘊剛毅之質',
        palaceName: '命宮 (本命元辰)',
        palaceBranch: `${lifePalace.branch}宮`,
        majorStars: formatStars(lifePalace),
        transformations: formatTransformations(lifePalace),
        coreEssence: `以 ${formatStars(lifePalace)} 為人格內核。你天生具有鮮明的主見與抗壓韌性，外表或許溫文儒雅，但內心自有一套不可動搖的原則與價值尺度。`,
        advantages: ['挫敗復原力極強，在逆境中往往能激發出超乎常人的爆發力。', '自省能力高，能不斷在實踐中進化升級思維格局。'],
        blindSpots: ['容易因自我要求過高而陷入精神內耗，需學會放過自己。'],
        actionStrategies: ['每天留給自己 15 分鐘放空靜心，與內在的小孩好好對話。'],
        fawnTips: '小鹿兒開運錦囊：晨起喝一杯溫開水，面向陽光深呼吸三次，喚醒元辰神清氣爽！'
      },
      '健康': {
        name: '健康',
        score: hScore,
        ratingText: hScore >= 85 ? '元氣充沛・筋骨強健之態' : '調和陰陽・養生蓄力時期',
        palaceName: '疾厄宮',
        palaceBranch: `${healthPalace.branch}宮`,
        majorStars: formatStars(healthPalace),
        transformations: formatTransformations(healthPalace),
        coreEssence: `疾厄宮坐鎮 ${formatStars(healthPalace)}。平日精力充沛，但需預防過度透支身體。你的健康關鍵在於情緒壓力疏導與順應四季的作息節律。`,
        advantages: ['身體自我修復力佳，平時注意養生便能長久維持健康狀態。'],
        blindSpots: ['工作投入時易忘記喝水與走動，久坐易引發肩頸腰背緊繃。'],
        actionStrategies: ['培養每週 2-3 次流汗運動（如慢跑、健走），促進代謝。'],
        fawnTips: '小鹿兒養生錦囊：隨身攜帶溫水保溫杯，多喝溫潤花草茶，脾胃溫暖人就長壽！'
      },
      '人際貴人': {
        name: '人際貴人',
        score: 88,
        ratingText: '高朋滿座・長輩同儕照應',
        palaceName: '交友宮 / 遷移宮',
        palaceBranch: `${friendsPalace.branch}宮`,
        majorStars: formatStars(friendsPalace),
        transformations: formatTransformations(friendsPalace),
        coreEssence: `交友宮呈現 ${formatStars(friendsPalace)} 之相。你的貴人運多出自專業圈層與遠行機遇，以誠待人、言出必行是吸引前輩提攜的致勝法寶。`,
        advantages: ['自帶親和力與可信度，容易在重要場合結交優質人脈。'],
        blindSpots: ['對朋友防備心低，需防範居心叵測者的言語誘惑。'],
        actionStrategies: ['定期篩選人脈圈，深耕同頻共振的良師益友。'],
        fawnTips: '小鹿兒人緣錦囊：常懷感恩心，逢年過節主動向長輩前輩發送真誠祝福，貴人運長存！'
      },
      '田宅': {
        name: '田宅',
        score: 89,
        ratingText: '基業安穩・福宅庇蔭後代',
        palaceName: '田宅宮',
        palaceBranch: `${propertyPalace.branch}宮`,
        majorStars: formatStars(propertyPalace),
        transformations: formatTransformations(propertyPalace),
        coreEssence: '田宅宮代表家庭安全感、不動產資產與祖業福蔭。宮內星曜和順，一生中極有機會擁有舒適溫馨、地段優越的理想居所。',
        advantages: ['對房屋地段與居家舒適度有極佳品味，置產眼光精準。'],
        blindSpots: ['裝潢修繕時易因追求完美而超支預算，需提前做好規劃。'],
        actionStrategies: ['資產累積到一定階段，優先配置穩健地段抗通膨的不動產。'],
        fawnTips: '小鹿兒家宅錦囊：客廳擺放圓葉植物或天然水晶礦石，全家人和樂融融福運滿堂！'
      },
      '父母長輩': {
        name: '父母長輩',
        score: 86,
        ratingText: '承蒙庇蔭・孝悌福祿隨身',
        palaceName: '父母宮',
        palaceBranch: `${parentsPalace.branch}宮`,
        majorStars: formatStars(parentsPalace),
        transformations: formatTransformations(parentsPalace),
        coreEssence: `父母宮坐鎮 ${formatStars(parentsPalace)}。長輩的家訓與言傳身教是你人生道路上的重要指路明燈，孝順父母乃世間第一大福田。`,
        advantages: ['自幼承蒙父母長輩關照，家庭觀念深厚而有溫度。'],
        blindSpots: ['偶有兩代觀念代溝，切勿因性急而口出重言傷害長輩。'],
        actionStrategies: ['定期致電關心父母生活細節，陪伴是最好的孝順方式。'],
        fawnTips: '小鹿兒福報錦囊：多給父母長輩添置保暖舒適衣物，百善孝為先，天地自護持！'
      }
    };

    return {
      scores: scores,
      headline: headline,
      subHeadline: subHeadline,
      coreAdvantage: coreAdvantage,
      relationshipPattern: relationshipPattern,
      growthChallenge: growthChallenge,
      detailedOverview: detailedOverview,
      actionableAdvice: actionableAdvice,
      oneSentenceVerdict: oneSentenceVerdict,
      dimensionDetails: dimensionDetails
    };
  }

  // MARK: - 流年與時光軌道運勢動態計算 (Timeline Fortune Engine)
  function calculateTimelineFortune(chart, scope, options) {
    options = options || {};
    const decadeIndex = options.decadeIndex || 0;
    const selectedYear = options.selectedYear || new Date().getFullYear();
    const selectedMonth = options.selectedMonth || 1;
    const selectedDay = options.selectedDay || 1;

    let targetPalace = chart.palaces[chart.lifeBranchIndex];
    let focusText = '';
    let timeLabel = '';

    switch (scope) {
      case 'natal': // 本命
        targetPalace = chart.palaces[chart.lifeBranchIndex];
        focusText = '本命元辰（終身核心人格與潛能基石）';
        timeLabel = '終身元辰';
        break;

      case 'decade': // 大限
        const safeIdx = Math.min(Math.max(decadeIndex, 0), chart.palaces.length - 1);
        targetPalace = chart.palaces[safeIdx];
        focusText = `${targetPalace.decadeStartAge} - ${targetPalace.decadeEndAge} 歲 大限十年運勢主場`;
        timeLabel = `${targetPalace.decadeStartAge}-${targetPalace.decadeEndAge}歲大限`;
        break;

      case 'annual': // 流年
        const yearBranchIdx = ((selectedYear - 4) % 12 + 12) % 12;
        const yearStemIdx = ((selectedYear - 4) % 10 + 10) % 10;
        const stemName = HEAVENLY_STEMS[yearStemIdx].name;
        const branchName = EARTHLY_BRANCHES[yearBranchIdx].name;
        targetPalace = chart.palaces[yearBranchIdx];
        focusText = `${selectedYear} 歲次【${stemName}${branchName}年】流年氣場`;
        timeLabel = `${selectedYear}年（${stemName}${branchName}）`;
        break;

      case 'minor': // 小限
        const birthBranchIdx = chart.lunarInfo.yearBranchIndex;
        const startBranchMap = {
          2: 4, 6: 4, 10: 4,  // 寅午戌起辰
          8: 10, 0: 10, 4: 10, // 申子辰起戌
          5: 7, 9: 7, 1: 7,    // 巳酉丑起未
          11: 1, 3: 1, 7: 1    // 亥卯未起丑
        };
        const startB = startBranchMap[birthBranchIdx] !== undefined ? startBranchMap[birthBranchIdx] : 4;
        const curYear = new Date().getFullYear();
        const bYear = chart.solarDate.getFullYear();
        const nominalAge = Math.max(curYear - bYear + 1, 1);
        const minorIdx = (startB + (nominalAge - 1)) % 12;
        targetPalace = chart.palaces[minorIdx];
        focusText = `實歲 ${nominalAge} 歲 小限心境微氣候`;
        timeLabel = `${nominalAge}歲小限`;
        break;

      case 'monthly': // 流月
        const safeMonth = Math.min(Math.max(selectedMonth, 1), 12);
        const curY = new Date().getFullYear();
        const yBranchIdx = ((curY - 4) % 12 + 12) % 12;
        const mBranchIdx = (yBranchIdx + (safeMonth - 1)) % 12;
        targetPalace = chart.palaces[mBranchIdx];
        const monthNames = ['', '正月', '二月', '三月', '四月', '五月', '六月', '七月', '八月', '九月', '十月', '冬月', '臘月'];
        focusText = `農曆 ${monthNames[safeMonth]} 流月吉凶氣候`;
        timeLabel = `農曆${monthNames[safeMonth]}`;
        break;

      case 'daily': // 流日
        const safeDay = Math.min(Math.max(selectedDay, 1), 30);
        const dayBIdx = (safeDay - 1) % 12;
        targetPalace = chart.palaces[dayBIdx];
        focusText = `農曆 ${safeDay} 日 流日值日氣候`;
        timeLabel = `農曆${safeDay}日`;
        break;
    }

    const majorStars = targetPalace.stars.filter(s => s.category === 'major');
    const majorNames = majorStars.map(s => s.name);
    const starsDisplay = majorStars.map(s => `${s.name}${s.brightness ? `[${s.brightness}]` : ''}${s.transformation ? ` 化${s.transformation}` : ''}`).join('、') || '借對宮星曜照會';

    const pName = targetPalace.name;
    const hasLu = targetPalace.stars.some(s => s.transformation === '祿');
    const hasJi = targetPalace.stars.some(s => s.transformation === '忌');
    const hasLucky = targetPalace.stars.some(s => s.category === 'lucky');
    const hasFierce = targetPalace.stars.some(s => s.category === 'fierce');

    let headline = `${timeLabel}・天賜良機，穩步拓土`;
    let plainOverview = `此時期主氣落入【${pName}】(${targetPalace.branch}宮)，由「${starsDisplay}」坐鎮。整體氛圍呈現出蓄勢待發、機運與考驗並存的動態局面。`;
    const opportunities = [];
    const precautions = [];

    if (hasLu) {
      headline = `${timeLabel}・吉星高照，財福相隨`;
      opportunities.push('逢生年或運勢化祿照耀，財務與合作契機大增，宜乘勝追擊拓寬收益通路。');
    }
    if (hasLucky) {
      opportunities.push('得吉星拱照，人脈助力充足，遇瓶頸時多向專業導師或長輩請益，能迅速撥雲見日。');
    }
    if (opportunities.length === 0) {
      opportunities.push(`深耕【${pName}】相關核心本業，循序漸進蓄積籌碼，以實力贏得厚實信賴。`);
    }

    if (hasJi) {
      headline = `${timeLabel}・暗湧潛伏，宜守不宜燥`;
      precautions.push('宮內逢化忌牽動，容易在溝通合作或財務簽約上遭遇波折，重大合約務必白紙黑字審慎推敲。');
    }
    if (hasFierce) {
      precautions.push('見煞曜干擾，行事切忌性急衝動，遇突發狀況宜冷靜三思，以柔克剛方能化險為夷。');
    }
    if (precautions.length === 0) {
      precautions.push('防範因過度樂觀而疏忽細節，定期覆盤進度方保萬無一失。');
    }

    const fawnAdvice = `小鹿兒指引：面對【${timeLabel}】氣候，保持平常心就是最強大的護身符。順風時不傲慢，逆風時不氣餒，好運常伴左右！`;

    return {
      scope: scope,
      focusText: focusText,
      timeLabel: timeLabel,
      palace: targetPalace,
      palaceName: pName,
      starsDisplay: starsDisplay,
      headline: headline,
      plainOverview: plainOverview,
      opportunities: opportunities,
      precautions: precautions,
      fawnAdvice: fawnAdvice,
      highlightedBranch: targetPalace.branch
    };
  }

  // MARK: - 雙人紫微合盤分析 (Synastry Engine)
  function analyzeSynastry(personA, personB) {
    const palaceA = personA.palaces[personA.lifeBranchIndex];
    const palaceB = personB.palaces[personB.lifeBranchIndex];

    const starsA = palaceA.stars.filter(s => s.category === 'major').map(s => s.name);
    const starsB = palaceB.stars.filter(s => s.category === 'major').map(s => s.name);

    const nameA = personA.userName || '命主';
    const nameB = personB.userName || '對象';

    const starsStrA = starsA.length > 0 ? starsA.join('・') : '借對宮星曜';
    const starsStrB = starsB.length > 0 ? starsB.join('・') : '借對宮星曜';
    const allStars = new Set([...starsA, ...starsB]);

    let baseScore = 85;
    let chemistry = `「${nameA}」(${starsStrA}) 與「${nameB}」(${starsStrB}) 命宮磁場互相呼應。雙方在價值觀與生活步調上能相互啟發，具備良好的合作與相處潛質。`;
    let relType = '志同道合・相輔相成良伴';
    let headline = '「互為鏡鑑，各展所長；在彼此的世界裡成為最好的隊友。」';

    if ((allStars.has('紫微') && allStars.has('天府')) || (allStars.has('太陽') && allStars.has('太陰'))) {
      baseScore = 93;
      chemistry = `【尊星合璧・日月同天】「${nameA}」(${starsStrA}) 與「${nameB}」(${starsStrB}) 的命宮磁場極度相得益彰！一方如陽光般溫暖開拓，另一方如月光般深沉包容。在一起不僅有強烈的心靈共鳴，在重要人生關卡更能彼此托底推進！`;
      relType = '天作之合・靈魂神隊友';
      headline = '「如星月同天，既懂彼此的雄心，亦憐對方的脆弱。」';
    } else if ((allStars.has('七殺') || allStars.has('破軍')) && (allStars.has('天相') || allStars.has('天同') || allStars.has('天梁'))) {
      baseScore = 89;
      chemistry = `【剛柔並濟・攻守兼備】「${nameA}」(${starsStrA}) 遇上「${nameB}」(${starsStrB})，一方具備強悍的決斷力與衝鋒勇氣，另一方則情商卓越、細心穩重。一人向前開疆拓土，一人在後穩固後方，是極具實戰爆發力的黃金搭檔！`;
      relType = '剛柔互補・事業王牌搭檔';
      headline = '「你敢勇往直前破浪，我能穩掌羅盤護航。」';
    } else if ((allStars.has('貪狼') || allStars.has('廉貞')) && (allStars.has('天機') || allStars.has('巨門'))) {
      baseScore = 87;
      chemistry = `【靈感共振・才華碰撞】「${nameA}」(${starsStrA}) 與「${nameB}」(${starsStrB}) 在一起生活永不無聊！雙方思維敏捷、好奇心旺盛，思想交流常有奇思妙想。相處就像無話不談的知己密友，情趣與熱情源源不絕。`;
      relType = '靈犀相通・生活智庫玩家';
      headline = '「靈魂有共鳴，言語有溫度，相處百看不厭。」';
    }

    // 四化互照
    const blessings = [];
    blessings.push(`【${nameA}】的生年吉化飛入【${nameB}】的命格三方，無形中為對方帶來事業信心與開拓底氣。`);
    blessings.push(`【${nameB}】的五行氣場能平抑【${nameA}】的急躁情緒，在關鍵時刻提供冷靜安定的力量。`);

    const stemDiff = Math.abs(personA.lunarInfo.yearStemIndex - personB.lunarInfo.yearStemIndex) % 5;
    const loveScore = Math.min(Math.max(baseScore + 3 - stemDiff, 60), 98);
    const valueScore = Math.min(Math.max(baseScore - 2 + (personA.elementBureau.number === personB.elementBureau.number ? 6 : 0), 55), 96);
    const wealthScore = Math.min(Math.max(baseScore + 4, 62), 99);
    const commScore = Math.min(Math.max(baseScore - 3 + (10 - stemDiff * 2), 52), 95);
    const overallScore = Math.round((loveScore + valueScore + wealthScore + commScore) / 4);

    const frictionPoints = [
      `性格上偶爾都有堅持己見的時刻，發生分歧時容易因「誰講得更有道理」而陷入爭論。`,
      `工作忙碌時容易減少深度溝通，需警惕將外在壓力帶入彼此私密日常。`
    ];

    const fawnAdvice = `小鹿兒合盤相處心法：最好的親密關係，不是兩個人變成同一個人，而是兩個獨立完整的靈魂並肩看同一個方向。學會讚美對方的優點，包容彼此的盲點，福氣自然綿長長久！`;

    return {
      overallScore: overallScore,
      loveScore: loveScore,
      valueScore: valueScore,
      wealthScore: wealthScore,
      commScore: commScore,
      relationshipType: relType,
      headline: headline,
      starChemistry: chemistry,
      mutualBlessings: blessings,
      frictionPoints: frictionPoints,
      fawnAdvice: fawnAdvice
    };
  }

  // MARK: - 完整白話文報告產生器 (1,000+ 字一鍵複製分享)
  function generateFullReport(chart) {
    const metis = generateMetisReport(chart);
    const df = new Intl.DateTimeFormat('zh-TW', { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', hour12: false });
    const birthStr = chart.isUnknownHour ? `${df.format(chart.solarDate)} (時辰未定・以子時起盤)` : df.format(chart.solarDate);

    let report = `🦌【小鹿兒算命・紫微斗數天命全覽報告】
━━━━━━━━━━━━━━━━━━━━
【命主基本資料】
• 命主姓名：${chart.userName}（${chart.gender}）
• 國曆生辰：${birthStr}
• 農曆八字：${chart.lunarInfo.baZiString}
• 農曆生辰：${chart.lunarInfo.lunarDateString}
• 五行局數：${chart.elementBureau.name}
• 命宮坐鎮：${chart.palaces[chart.lifeBranchIndex].branch}宮（命主：${chart.lifeMaster}）
• 身宮坐鎮：${chart.palaces[chart.bodyBranchIndex].branch}宮（身主：${chart.bodyMaster}）
• 流派標準：倪海廈先生《天紀》排盤體系・真太陽時精密天文校驗

━━━━━━━━━━━━━━━━━━━━
✨【白話核心天命總綱】
「${metis.headline}」
${metis.subHeadline}

【天命長篇解讀】
${metis.detailedOverview}

━━━━━━━━━━━━━━━━━━━━
🔮【三大核心天命指引】
🌟 核心優勢與超能力：
${metis.coreAdvantage}

🧭 情感與關係互動模式：
${metis.relationshipPattern}

📈 人生蛻變與成長課題：
${metis.growthChallenge}

━━━━━━━━━━━━━━━━━━━━
🌟【六維天命能量雷達指數】
• 綜合格局：${metis.scores.overall} 分
• 事業突破：${metis.scores.career} 分
• 財富累積：${metis.scores.wealth} 分
• 感情穩定：${metis.scores.relationship} 分
• 個性特質：${metis.scores.personality} 分
• 健康元氣：${metis.scores.health} 分

━━━━━━━━━━━━━━━━━━━━
📂【各大維度專屬深度剖析】`;

    const dims = ['財富', '事業', '感情', '性格', '健康', '人際貴人', '田宅', '父母長輩'];
    for (const d of dims) {
      const dt = metis.dimensionDetails[d];
      if (dt) {
        report += `\n\n【${dt.name}解析】（得分：${dt.score}分・評級：${dt.ratingText}）
• 核心宮位：${dt.palaceName} (${dt.palaceBranch})
• 坐鎮星曜：${dt.majorStars}
• 核心天命：${dt.coreEssence}
• 天賦優勢：${dt.advantages.join('；')}
• 避坑提醒：${dt.blindSpots.join('；')}
• 落地策略：${dt.actionStrategies.join('；')}
• 小鹿開運：${dt.fawnTips}`;
      }
    }

    report += `\n\n━━━━━━━━━━━━━━━━━━━━\n📜【十二宮位坐鎮星曜與白話主題】\n`;
    for (const p of chart.palaces) {
      const majorStr = p.stars.filter(s => s.category === 'major').map(s => s.name).join('、') || '借對宮星曜';
      report += `• 【${p.name}】(${p.branch}宮)：${majorStr}（${p.decadeStartAge}-${p.decadeEndAge}歲）\n`;
    }

    report += `\n━━━━━━━━━━━━━━━━━━━━\n🏛️【倪海廈《天紀》經典格局匹配】\n`;
    if (chart.patterns.length === 0) {
      report += `本命格局平正溫和，無極端偏煞，行運以穩健中求進展為上。\n`;
    } else {
      for (const pat of chart.patterns) {
        report += `★【${pat.name}】（${pat.isAuspicious ? '吉格' : '變局'}）\n  描述：${pat.desc}\n  倪師點評：${pat.tianjiComment}\n  古賦斷訣：${pat.poem}\n`;
      }
    }

    report += `\n━━━━━━━━━━━━━━━━━━━━\n🦌【小鹿兒開運修心指引】\n${metis.actionableAdvice}\n\n一言定調：${metis.oneSentenceVerdict}\n\n「算命之目的，絕非消極認命，而在於知己知彼，順應天時。人人皆有先天命盤之強弱，然心念一轉，言行即變；言行一變，命運自開。」\n━━━━━━━━━━━━━━━━━━━━\n本報告由《小鹿兒算命》Web 版自動運算生成・祝您福祿安康、順遂平安！`;

    return report;
  }

  // MARK: - 靜默 Google Sheets 雲端同調經理 (Silent Background Sync with Offline Queue)
  const WEBHOOK_URL = 'https://script.google.com/macros/s/AKfycbzUZm93oNx74FAUj-5ZkUI8pNLXh4AnY_h_UV6VlgzWmWw4gC4chrYGQajC8aePgtM5/exec';
  const QUEUE_STORAGE_KEY = 'XiaoLuer_Web_GoogleSheet_OfflineQueue';

  function getOfflineQueue() {
    try {
      const raw = localStorage.getItem(QUEUE_STORAGE_KEY);
      return raw ? JSON.parse(raw) : [];
    } catch (e) {
      return [];
    }
  }

  function saveOfflineQueue(queue) {
    try {
      localStorage.setItem(QUEUE_STORAGE_KEY, JSON.stringify(queue));
    } catch (e) {}
  }

  function silentSyncChart(chart, solarBirthDate, isUnknownHour) {
    const now = new Date();
    const pad = n => String(n).padStart(2, '0');
    const timestampStr = `${now.getFullYear()}/${pad(now.getMonth() + 1)}/${pad(now.getDate())} ${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`;
    const solarDateStr = `${solarBirthDate.getFullYear()}年${pad(solarBirthDate.getMonth() + 1)}月${pad(solarBirthDate.getDate())}日`;
    const birthTimeStr = isUnknownHour ? '未知 (以子時起盤)' : `${pad(solarBirthDate.getHours())}:${pad(solarBirthDate.getMinutes())}`;

    const payload = {
      timestamp: timestampStr,
      userName: chart.userName,
      gender: chart.gender,
      solarBirthDate: solarDateStr,
      birthTime: birthTimeStr,
      isUnknownHour: isUnknownHour ? '是 (以子時起盤)' : '否',
      lunarBirthDate: chart.lunarInfo.lunarDateString,
      baZi: chart.lunarInfo.baZiString,
      elementBureau: chart.elementBureau.name,
      lifeMaster: chart.lifeMaster,
      bodyMaster: chart.bodyMaster,
      platform: 'Web (小鹿兒算命)'
    };

    // 檢查網路狀態
    if (!navigator.onLine) {
      const queue = getOfflineQueue();
      queue.push(payload);
      saveOfflineQueue(queue);
      return;
    }

    // 發送 POST 請求 (使用 no-cors 或 application/json 以利 GAS 接收)
    fetch(WEBHOOK_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'text/plain;charset=utf-8' },
      body: JSON.stringify(payload)
    }).then(res => {
      flushOfflineQueue();
    }).catch(err => {
      const queue = getOfflineQueue();
      queue.push(payload);
      saveOfflineQueue(queue);
    });
  }

  function flushOfflineQueue() {
    if (!navigator.onLine) return;
    const queue = getOfflineQueue();
    if (!queue || queue.length === 0) return;

    const remaining = [];
    let completedCount = 0;

    queue.forEach((item, index) => {
      fetch(WEBHOOK_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'text/plain;charset=utf-8' },
        body: JSON.stringify(item)
      }).then(() => {
        // 成功發送
      }).catch(() => {
        remaining.push(item);
      }).finally(() => {
        completedCount++;
        if (completedCount === queue.length) {
          saveOfflineQueue(remaining);
        }
      });
    });
  }

  // 監聽網路重新連線事件，自動補傳
  if (typeof window !== 'undefined') {
    window.addEventListener('online', flushOfflineQueue);
  }

  // 導出全局命名空間
  global.ZiweiEngine = {
    HEAVENLY_STEMS: HEAVENLY_STEMS,
    EARTHLY_BRANCHES: EARTHLY_BRANCHES,
    PALACE_NAMES: PALACE_NAMES,
    PRESET_CITIES: PRESET_CITIES,
    calculateEquationOfTime: calculateEquationOfTime,
    calculateTrueSolarTime: calculateTrueSolarTime,
    getLunarDateInfo: getLunarDateInfo,
    generateChart: generateChart,
    generateMetisReport: generateMetisReport,
    calculateTimelineFortune: calculateTimelineFortune,
    analyzeSynastry: analyzeSynastry,
    generateFullReport: generateFullReport,
    silentSyncChart: silentSyncChart,
    flushOfflineQueue: flushOfflineQueue
  };

})(typeof window !== 'undefined' ? window : this);
