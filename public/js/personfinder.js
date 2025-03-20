// APIキーとフィードURLの設定
const feedUrl = '/personfinder';

fetch(feedUrl)
  .then(response => {
    if (!response.ok) {
      throw new Error('ネットワークエラーが発生しました');
    }
    return response.text();
  })
  .then(xmlText => {
    // XMLをパースしてJSONに変換
    const parser = new DOMParser();
    const xmlDoc = parser.parseFromString(xmlText, 'application/xml');
    const entries = xmlDoc.getElementsByTagName('entry');
    const data = Array.from(entries).map(entry => {
      const personRecordId = entry.querySelector('person_record_id').textContent;
      const name = entry.querySelector('name').textContent;
      const entryDate = entry.querySelector('entry_date').textContent;
      return { personRecordId, name, entryDate };
    });
    console.log(data);
  })
  .catch(error => {
    console.error('データの取得中にエラーが発生しました:', error);
  });
