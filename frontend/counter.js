// アクセスカウンター：API Gateway → Lambda → DynamoDB を呼び出して表示する
const API_URL = "https://k8nzp59qa1.execute-api.ap-southeast-2.amazonaws.com/count";

async function updateVisitorCount() {
  const el = document.getElementById("visitor-count");
  try {
    const response = await fetch(API_URL, { cache: "no-store" });
    if (!response.ok) throw new Error("HTTP " + response.status);
    const data = await response.json();
    if (!Number.isSafeInteger(data.count) || data.count < 0) {
      throw new Error("Invalid count response");
    }
    el.textContent = data.count;
  } catch (error) {
    console.error("visitor counter error:", error);
    el.textContent = "---";
  }
}

updateVisitorCount();
