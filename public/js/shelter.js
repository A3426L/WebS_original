    function getCurrentLocation() {
      return new Promise((resolve, reject) => {
        if (navigator.geolocation) {
          navigator.geolocation.getCurrentPosition(resolve, reject);
        } else {
          reject(new Error("Geolocationがサポートされていない."));
        }
      });
    }

    // 2点間の距離を計算（Haversine Formula）
    function calculateDistance(lat1, lon1, lat2, lon2) {
      const R = 6371; // 地球の半径 (km)
      const dLat = (lat2 - lat1) * (Math.PI / 180);
      const dLon = (lon2 - lon1) * (Math.PI / 180);
      const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(lat1 * (Math.PI / 180)) * Math.cos(lat2 * (Math.PI / 180)) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
      const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
      return R * c; // 距離 (km)
    }

    // GeoJSONファイルを読み込む
    async function loadGeoJSON() {
      try {
        const response = await fetch('data/shelter/mergeFromCity_1.geojson');
        const data = await response.json();
        return data;
      } catch (error) {
        console.error("GeoJSONの読み込みに失敗しました:", error);
        throw error;
      }
    }

    // メイン処理：最寄りの避難場所を取得して HTML に反映
    async function findNearestLocations() {
      try {
        const geojson = await loadGeoJSON();

        const position = await getCurrentLocation();
        const currentLat = position.coords.latitude;
        const currentLon = position.coords.longitude;

        // 各避難場所に現在地からの距離を追加
        geojson.features.forEach(feature => {
          const [lon, lat] = feature.geometry.coordinates;
          feature.properties.distance = calculateDistance(currentLat, currentLon, lat, lon);
        });

        // 距離順にソート
        geojson.features.sort((a, b) => a.properties.distance - b.properties.distance);

        // 最寄りの5件を取得
        const nearestLocations = geojson.features.slice(0, 5);
        nearestLocations.forEach((location, index) => {
          const facilityName = location.properties["施設・場所名"] || "不明";
          const distance = location.properties.distance.toFixed(2) + " km";
          const address = location.properties.住所 || '';
          const googleLink = `https://www.google.com/maps/place/${address}`;

          // 各HTML要素に値を代入
          const facilityElem = document.getElementById(`facility${index + 1}`);
          const distanceElem = document.getElementById(`distance${index + 1}`);
          const linkElem = document.getElementById(`link${index + 1}`);
          if (facilityElem) facilityElem.innerText = facilityName;
          if (distanceElem) distanceElem.innerText = `距離: ${distance}`;
          if (linkElem) {
            linkElem.href = googleLink;
            linkElem.innerText = "ここへ行く";
          }
        });
      } catch (error) {
        console.error("エラーが発生しました:", error);
      }
    }

    // ページ読み込み時に実行＆更新ボタンにイベント設定
    document.addEventListener("DOMContentLoaded", function() {
      findNearestLocations();
      document.getElementById('refreshBtn').addEventListener('click', findNearestLocations);
    });