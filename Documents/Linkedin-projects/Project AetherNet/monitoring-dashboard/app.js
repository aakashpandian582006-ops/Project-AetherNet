const btnScan = document.getElementById('btn-scan');
const btnInject = document.getElementById('btn-inject');
const btnRemedation = document.getElementById('btn-remediate');
const logBox = document.getElementById('terminal-log');
const tgwLink = document.getElementById('tgw-link');
const integrityVal = document.getElementById('metric-integrity');
const remediedCounter = document.getElementById('metric-remedied');
const globalStatus = document.getElementById('global-status');

let remedyCount = 13;

function addLog(message, type = 'info') {
  const time = new Date().toLocaleTimeString();
  const row = document.createElement('div');
  row.className = `log-row ${type}`;
  row.innerHTML = `[${time}] ${message}`;
  logBox.appendChild(row);
  logBox.scrollTop = logBox.scrollHeight;
}

btnScan.addEventListener('click', () => {
  addLog('[SYSTEM-SCANNER] Scanning local routing partitions against zero-trust policy ledger...', 'info');
  setTimeout(() => {
    addLog('[SYSTEM-SCANNER] SUCCESS: All endpoints match security templates.', 'success');
  }, 800);
});

btnInject.addEventListener('click', () => {
  addLog('[ALERT] Dynamic route injection detected! Bypass route 0.0.0.0/0 exposed via TGW-99999.', 'warning');
  tgwLink.className.baseVal = "net-link breached";
  integrityVal.textContent = "22% (CRITICAL)";
  integrityVal.className = "value alert-flash";
  globalStatus.textContent = "UNAUTHORIZED ROUTE LEAK DETECTED";
  globalStatus.className = "system-status critical";
  btnRemedation.disabled = false;
});

btnRemedation.addEventListener('click', () => {
  addLog('[AUTONOMIC-ENGINE] Instigating remediation routine...', 'info');
  setTimeout(() => {
    addLog('[AUTONOMIC-ENGINE] AWS command sent: DeleteRoute on rt-prod-public (Target: 0.0.0.0/0)', 'info');
    addLog('[SECURITY-CORE] AWS IAM verification passed. Route severed successfully.', 'success');
    addLog('[FIREWALL-CORE] Dynamic security action applied: INBOUND DENY (Rule 100) added for attacker IP 198.51.100.42/32 to NACL!', 'success');

    tgwLink.className.baseVal = "net-link secure";
    integrityVal.textContent = "100%";
    integrityVal.className = "value safe";
    globalStatus.textContent = "ALL BOUNDARIES SECURE";
    globalStatus.className = "system-status active";

    remedyCount++;
    remediedCounter.textContent = remedyCount;
    btnRemedation.disabled = true;
  }, 1200);
});