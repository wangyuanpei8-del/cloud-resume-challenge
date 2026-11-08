// 訪問者カウンター：API Gateway → Lambda → DynamoDB を呼び出して表示する
const API_URL = "https://k8nzp59qa1.execute-api.ap-southeast-2.amazonaws.com/count";

async function updateVisitorCount() {
  const el = document.getElementById("visitor-count");
  try {
    const response = await fetch(API_URL);
    if (!response.ok) throw new Error("HTTP " + response.status);
    const data = await response.json();
    el.textContent = data.count;
  } catch (error) {
    console.error("visitor counter error:", error);
    el.textContent = "---";
  }
}

updateVisitorCount();