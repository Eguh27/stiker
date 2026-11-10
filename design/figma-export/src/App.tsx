import { useMemo, useState, type ReactNode } from "react";

type View =
  | "library"
  | "gallery"
  | "queue"
  | "packs"
  | "packEditor"
  | "imageEditor"
  | "textEditor"
  | "removeBg"
  | "border"
  | "settings";

type DemoState = "normal" | "loading" | "empty" | "error";

const icons: Record<string, ReactNode> = {
  grid: (
    <>
      <rect x="4" y="4" width="6" height="6" rx="2" />
      <rect x="14" y="4" width="6" height="6" rx="2" />
      <rect x="4" y="14" width="6" height="6" rx="2" />
      <rect x="14" y="14" width="6" height="6" rx="2" />
    </>
  ),
  queue: (
    <>
      <path d="M8 6h12M8 12h12M8 18h12" />
      <circle cx="4" cy="6" r="1" />
      <circle cx="4" cy="12" r="1" />
      <circle cx="4" cy="18" r="1" />
    </>
  ),
  pack: (
    <>
      <path d="m12 3 9 5-9 5-9-5 9-5Z" />
      <path d="m3 12 9 5 9-5M3 16l9 5 9-5" />
    </>
  ),
  settings: (
    <>
      <circle cx="12" cy="12" r="3" />
      <path d="M19.4 15a1.8 1.8 0 0 0 .36 2l.06.06-2.83 2.83-.06-.06a1.8 1.8 0 0 0-2-.36 1.8 1.8 0 0 0-1.1 1.65V21h-4v-.09A1.8 1.8 0 0 0 8.7 19.3a1.8 1.8 0 0 0-2 .36l-.06.06-2.83-2.83.06-.06a1.8 1.8 0 0 0 .36-2A1.8 1.8 0 0 0 2.6 13.7H2.5v-4h.09A1.8 1.8 0 0 0 4.2 8.6a1.8 1.8 0 0 0-.36-2l-.06-.06 2.83-2.83.06.06a1.8 1.8 0 0 0 2 .36A1.8 1.8 0 0 0 9.8 2.5V2.4h4v.09a1.8 1.8 0 0 0 1.1 1.64 1.8 1.8 0 0 0 2-.36l.06-.06 2.83 2.83-.06.06a1.8 1.8 0 0 0-.36 2 1.8 1.8 0 0 0 1.64 1.1h.09v4H21a1.8 1.8 0 0 0-1.6 1.3Z" />
    </>
  ),
  plus: <path d="M12 5v14M5 12h14" />,
  sun: (
    <>
      <circle cx="12" cy="12" r="4" />
      <path d="M12 2v2M12 20v2M4.93 4.93l1.42 1.42M17.65 17.65l1.42 1.42M2 12h2M20 12h2M4.93 19.07l1.42-1.42M17.65 6.35l1.42-1.42" />
    </>
  ),
  moon: <path d="M21 12.8A9 9 0 1 1 11.2 3 7 7 0 0 0 21 12.8Z" />,
  back: <path d="m15 18-6-6 6-6" />,
  more: (
    <>
      <circle cx="5" cy="12" r="1" />
      <circle cx="12" cy="12" r="1" />
      <circle cx="19" cy="12" r="1" />
    </>
  ),
  image: (
    <>
      <rect x="3" y="4" width="18" height="16" rx="3" />
      <circle cx="9" cy="10" r="2" />
      <path d="m21 15-4-4L5 20" />
    </>
  ),
  folder: (
    <path d="M3 6.5A2.5 2.5 0 0 1 5.5 4H9l2 2h7.5A2.5 2.5 0 0 1 21 8.5v8a2.5 2.5 0 0 1-2.5 2.5h-13A2.5 2.5 0 0 1 3 16.5v-10Z" />
  ),
  check: <path d="m5 12 4 4L19 6" />,
  close: <path d="m6 6 12 12M18 6 6 18" />,
  refresh: (
    <>
      <path d="M20 11a8 8 0 1 0-2.34 5.66" />
      <path d="M20 4v7h-7" />
    </>
  ),
  cloud: (
    <>
      <path d="M17.5 19H6a4 4 0 1 1 1-7.87A6 6 0 0 1 18.8 9.5 4.8 4.8 0 0 1 17.5 19Z" />
      <path d="m9 14 3 3 3-3M12 9v8" />
    </>
  ),
  edit: (
    <>
      <path d="M12 20h9" />
      <path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L8 18l-4 1 1-4Z" />
    </>
  ),
  text: (
    <>
      <path d="M5 6V4h14v2M9 20h6M12 4v16" />
    </>
  ),
  brush: (
    <>
      <path d="m14.5 4.5 5 5L11 18H6v-5Z" />
      <path d="M6 18c0 2-1 3-3 3 0-2 1-3 3-3Z" />
    </>
  ),
  erase: (
    <>
      <path d="m7 19-4-4 10-10a2.8 2.8 0 0 1 4 0l2 2a2.8 2.8 0 0 1 0 4l-8 8Z" />
      <path d="m11 19 6-6M7 19h14" />
    </>
  ),
  border: (
    <>
      <path d="M12 3c3 2 7 2 8 6s-3 5-3 8-3 4-6 3-5 1-7-2 0-5 0-8 4-5 8-9Z" />
      <path d="M12 7c2 1 4 1 4 4s-2 3-2 5-4 2-5 0-1-3-1-5 2-3 4-4Z" />
    </>
  ),
  sticker: (
    <path d="M12 3c5 0 9 3 9 8 0 6-4 10-10 10-5 0-8-4-8-9 0-6 3-9 9-9Zm9 8c-5-1-9 3-10 10" />
  ),
  undo: (
    <>
      <path d="m9 7-5 5 5 5" />
      <path d="M20 17a8 8 0 0 0-13-6" />
    </>
  ),
  redo: (
    <>
      <path d="m15 7 5 5-5 5" />
      <path d="M4 17a8 8 0 0 1 13-6" />
    </>
  ),
  layers: (
    <>
      <path d="m12 2 9 5-9 5-9-5 9-5Z" />
      <path d="m3 12 9 5 9-5M3 17l9 5 9-5" />
    </>
  ),
  download: (
    <>
      <path d="M12 3v12M7 10l5 5 5-5" />
      <path d="M5 21h14" />
    </>
  ),
  upload: (
    <>
      <path d="M12 21V9M7 14l5-5 5 5" />
      <path d="M5 3h14" />
    </>
  ),
  chevron: <path d="m9 18 6-6-6-6" />,
  type: (
    <>
      <path d="M4 7V4h16v3M9 20h6M12 4v16" />
    </>
  ),
  palette: (
    <>
      <circle cx="13.5" cy="6.5" r=".5" />
      <circle cx="17.5" cy="10.5" r=".5" />
      <circle cx="8.5" cy="7.5" r=".5" />
      <path d="M12 3a9 9 0 0 0 0 18h1.5a2 2 0 0 0 0-4H12a2 2 0 0 1 0-4h3a6 6 0 0 0 0-12Z" />
    </>
  ),
  database: (
    <>
      <ellipse cx="12" cy="5" rx="8" ry="3" />
      <path d="M4 5v6c0 1.7 3.6 3 8 3s8-1.3 8-3V5" />
      <path d="M4 11v6c0 1.7 3.6 3 8 3s8-1.3 8-3v-6" />
    </>
  ),
};

function Icon({ name, size = 22 }: { name: string; size?: number }) {
  return (
    <svg
      aria-hidden="true"
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.8"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      {icons[name]}
    </svg>
  );
}

const stickers = [
  { label: "OK!", kind: "lavender", shape: "burst" },
  { label: "YAY", kind: "peach", shape: "flower" },
  { label: "HI!", kind: "mint", shape: "blob" },
  { label: "WOW", kind: "blue", shape: "cloud" },
  { label: "LOL", kind: "yellow", shape: "burst" },
  { label: "NICE", kind: "pink", shape: "blob" },
  { label: "GO!", kind: "mint", shape: "flower" },
  { label: "YES", kind: "lavender", shape: "cloud" },
];

function StickerArt({ index, small = false }: { index: number; small?: boolean }) {
  const s = stickers[index % stickers.length];
  return (
    <div className={`sticker-art ${s.kind} ${s.shape} ${small ? "small" : ""}`}>
      <span>{s.label}</span>
      <i />
    </div>
  );
}

function TopBar({
  title,
  back,
  action,
  onBack,
}: {
  title: string;
  back?: boolean;
  action?: ReactNode;
  onBack?: () => void;
}) {
  return (
    <header className="top-bar">
      <div className="top-title">
        {back && (
          <button className="icon-button" onClick={onBack} aria-label="Kembali">
            <Icon name="back" />
          </button>
        )}
        <div>
          <p className="eyebrow">{back ? "Sticker Studio" : "Workspace lokal"}</p>
          <h1>{title}</h1>
        </div>
      </div>
      {action}
    </header>
  );
}

function BottomNav({ view, navigate }: { view: View; navigate: (v: View) => void }) {
  const items: { id: View; icon: string; label: string }[] = [
    { id: "library", icon: "grid", label: "Library" },
    { id: "queue", icon: "queue", label: "Antrean" },
    { id: "packs", icon: "pack", label: "Pack" },
    { id: "settings", icon: "settings", label: "Setelan" },
  ];
  return (
    <nav className="bottom-nav">
      {items.map((item) => (
        <button
          key={item.id}
          className={view === item.id ? "active" : ""}
          onClick={() => navigate(item.id)}
        >
          <Icon name={item.icon} />
          <span>{item.label}</span>
        </button>
      ))}
    </nav>
  );
}

function DemoStateMenu({
  value,
  onChange,
}: {
  value: DemoState;
  onChange: (s: DemoState) => void;
}) {
  const states: DemoState[] = ["normal", "loading", "empty", "error"];
  return (
    <button
      className="state-chip"
      onClick={() => onChange(states[(states.indexOf(value) + 1) % states.length])}
    >
      <span className={`state-dot ${value}`} />
      {value}
    </button>
  );
}

function StatePanel({
  state,
  type,
  retry,
}: {
  state: DemoState;
  type: string;
  retry?: () => void;
}) {
  if (state === "loading")
    return (
      <div className="state-panel">
        <div className="loader-ring" />
        <h3>Menyiapkan {type}</h3>
        <p>Semuanya diproses langsung di perangkatmu.</p>
      </div>
    );
  if (state === "empty")
    return (
      <div className="state-panel">
        <div className="state-icon">
          <Icon
            name={type === "antrean" ? "queue" : type === "pack" ? "pack" : "sticker"}
            size={30}
          />
        </div>
        <h3>Belum ada {type}</h3>
        <p>Mulai dari galeri atau impor beberapa gambar sekaligus.</p>
        <button className="secondary-button">
          <Icon name="plus" size={18} /> Mulai sekarang
        </button>
      </div>
    );
  return (
    <div className="state-panel error">
      <div className="state-icon">
        <Icon name="refresh" size={30} />
      </div>
      <h3>Gagal memuat {type}</h3>
      <p>File lokal mungkin dipindahkan. Periksa lalu coba lagi.</p>
      <button className="secondary-button" onClick={retry}>
        <Icon name="refresh" size={18} /> Coba lagi
      </button>
    </div>
  );
}

function Library({ navigate }: { navigate: (v: View) => void }) {
  const [tab, setTab] = useState("Semua");
  const [sheet, setSheet] = useState(false);
  const [state, setState] = useState<DemoState>("normal");
  return (
    <>
      <TopBar
        title="Sticker Library"
        action={
          <div className="header-actions">
            <DemoStateMenu value={state} onChange={setState} />
          </div>
        }
      />
      <main className="screen-content">
        <section className="hero-card">
          <div>
            <span className="hero-kicker">OFFLINE-FIRST</span>
            <h2>
              Koleksimu,
              <br />
              selalu siap.
            </h2>
            <p>48 stiker tersimpan lokal</p>
          </div>
          <div className="hero-stack">
            <StickerArt index={1} small />
            <StickerArt index={4} small />
          </div>
        </section>
        <div className="segmented">
          <button className={tab === "Semua" ? "active" : ""} onClick={() => setTab("Semua")}>
            Semua <span>48</span>
          </button>
          <button className={tab !== "Semua" ? "active" : ""} onClick={() => setTab("Inbox")}>
            Inbox / Baru <span>8</span>
          </button>
        </div>
        {state === "normal" ? (
          <div className="sticker-grid">
            {stickers.slice(0, tab === "Semua" ? 8 : 4).map((_, i) => (
              <button className="sticker-card" key={i} onClick={() => navigate("imageEditor")}>
                <StickerArt index={tab === "Semua" ? i : i + 2} />
                <span className="card-badge">
                  {tab === "Semua" ? ["Fun pack", "Daily", "Imported", "Daily"][i % 4] : "Baru"}
                </span>
              </button>
            ))}
          </div>
        ) : (
          <StatePanel state={state} type="stiker" retry={() => setState("normal")} />
        )}
      </main>
      <button className="fab" onClick={() => setSheet(true)} aria-label="Tambah stiker">
        <Icon name="plus" size={26} />
      </button>
      {sheet && (
        <div className="scrim" onClick={() => setSheet(false)}>
          <section className="bottom-sheet" onClick={(e) => e.stopPropagation()}>
            <div className="sheet-handle" />
            <div className="sheet-title">
              <div>
                <p className="eyebrow">Tambah ke library</p>
                <h2>Impor stiker</h2>
              </div>
              <button className="icon-button" onClick={() => setSheet(false)}>
                <Icon name="close" />
              </button>
            </div>
            <button className="sheet-option" onClick={() => navigate("gallery")}>
              <span>
                <Icon name="image" />
              </span>
              <div>
                <b>Dari galeri</b>
                <small>Pilih satu atau beberapa foto</small>
              </div>
              <Icon name="chevron" />
            </button>
            <button className="sheet-option" onClick={() => navigate("gallery")}>
              <span>
                <Icon name="folder" />
              </span>
              <div>
                <b>Bulk import</b>
                <small>Impor seluruh folder sekaligus</small>
              </div>
              <Icon name="chevron" />
            </button>
          </section>
        </div>
      )}
    </>
  );
}

function Gallery({ navigate }: { navigate: (v: View) => void }) {
  const [selected, setSelected] = useState<number[]>([0, 2, 5]);
  const toggle = (i: number) =>
    setSelected((v) => (v.includes(i) ? v.filter((x) => x !== i) : [...v, i]));
  return (
    <>
      <TopBar
        title="Pilih dari galeri"
        back
        onBack={() => navigate("library")}
        action={
          <button
            className="text-button"
            onClick={() =>
              setSelected(selected.length === 12 ? [] : Array.from({ length: 12 }, (_, i) => i))
            }
          >
            {selected.length === 12 ? "Hapus semua" : "Pilih semua"}
          </button>
        }
      />
      <main className="screen-content gallery-content">
        <div className="gallery-meta">
          <span>Terbaru</span>
          <span>{selected.length} terpilih</span>
        </div>
        <div className="photo-grid">
          {Array.from({ length: 12 }, (_, i) => (
            <button
              key={i}
              className={`photo-tile tile-${i % 6} ${selected.includes(i) ? "selected" : ""}`}
              onClick={() => toggle(i)}
            >
              <StickerArt index={i} />
              <span className="select-check">
                {selected.includes(i) && <Icon name="check" size={15} />}
              </span>
            </button>
          ))}
        </div>
      </main>
      <div className="sticky-action">
        <div>
          <b>{selected.length} file</b>
          <small>PNG · JPG · WEBP</small>
        </div>
        <button
          className="primary-button"
          disabled={!selected.length}
          onClick={() => navigate("queue")}
        >
          Import <Icon name="download" size={18} />
        </button>
      </div>
    </>
  );
}

const queueItems = [
  { title: "IMG_2841.webp", status: "Downloading", progress: 68, art: 2 },
  { title: "weekend-pack.zip", status: "Pending", progress: 0, art: 5 },
  { title: "IMG_2838.png", status: "Gagal", progress: 36, art: 7 },
];

function Queue({ navigate }: { navigate: (v: View) => void }) {
  const [auto, setAuto] = useState(true);
  const [state, setState] = useState<DemoState>("normal");
  const [retried, setRetried] = useState(false);
  return (
    <>
      <TopBar title="Queue Monitor" action={<DemoStateMenu value={state} onChange={setState} />} />
      <main className="screen-content">
        <section className="toggle-card">
          <div className="setting-icon">
            <Icon name="erase" />
          </div>
          <div>
            <b>Auto-RMBG</b>
            <small>Hapus latar saat impor</small>
          </div>
          <button className={`switch ${auto ? "on" : ""}`} onClick={() => setAuto(!auto)}>
            <span />
          </button>
        </section>
        <div className="section-heading">
          <div>
            <p className="eyebrow">AKTIVITAS</p>
            <h2>3 item</h2>
          </div>
          <span className="live-label">
            <i /> Lokal
          </span>
        </div>
        {state === "normal" ? (
          <div className="queue-list">
            {queueItems.map((item, i) => {
              const fixed = i === 2 && retried;
              const status = fixed ? "Downloading" : item.status;
              const progress = fixed ? 54 : item.progress;
              return (
                <article className="queue-card" key={item.title}>
                  <div className="queue-art">
                    <StickerArt index={item.art} small />
                  </div>
                  <div className="queue-info">
                    <div>
                      <b>{item.title}</b>
                      <small className={`status ${status.toLowerCase()}`}>{status}</small>
                    </div>
                    {status === "Pending" ? (
                      <p>Menunggu proses sebelumnya</p>
                    ) : (
                      <div className="progress-wrap">
                        <div className="progress-track">
                          <i style={{ width: `${progress}%` }} />
                        </div>
                        <span>{progress}%</span>
                      </div>
                    )}
                  </div>
                  {status === "Gagal" && (
                    <button className="retry-button" onClick={() => setRetried(true)}>
                      <Icon name="refresh" size={17} /> Retry
                    </button>
                  )}
                </article>
              );
            })}
          </div>
        ) : (
          <StatePanel state={state} type="antrean" retry={() => setState("normal")} />
        )}
        <section className="privacy-note">
          <Icon name="cloud" />
          <div>
            <b>Tetap privat</b>
            <p>Tidak ada gambar yang dikirim ke cloud. Semua proses berjalan di perangkat ini.</p>
          </div>
        </section>
      </main>
      <BottomNav view="queue" navigate={navigate} />
    </>
  );
}

const packs = [
  { name: "Daily Mood", count: 18, sync: true, arts: [0, 2, 4] },
  { name: "Weekend Club", count: 12, sync: false, arts: [1, 3, 6] },
  { name: "Office Signals", count: 7, sync: true, arts: [7, 5, 0] },
];

function Packs({ navigate }: { navigate: (v: View) => void }) {
  const [state, setState] = useState<DemoState>("normal");
  return (
    <>
      <TopBar title="Sticker Packs" action={<DemoStateMenu value={state} onChange={setState} />} />
      <main className="screen-content">
        <div className="section-heading packs-heading">
          <div>
            <p className="eyebrow">KOLEKSI</p>
            <h2>Pack milikmu</h2>
          </div>
          <button className="round-add" onClick={() => navigate("packEditor")}>
            <Icon name="plus" />
          </button>
        </div>
        {state === "normal" ? (
          <div className="pack-list">
            {packs.map((pack) => (
              <button className="pack-card" key={pack.name} onClick={() => navigate("packEditor")}>
                <div className="pack-preview">
                  {pack.arts.map((a, i) => (
                    <div key={a} style={{ zIndex: 3 - i }}>
                      <StickerArt index={a} small />
                    </div>
                  ))}
                </div>
                <div className="pack-copy">
                  <h3>{pack.name}</h3>
                  <p>{pack.count} stiker</p>
                  <span className={pack.sync ? "synced" : "not-synced"}>
                    {pack.sync ? (
                      <Icon name="check" size={14} />
                    ) : (
                      <Icon name="refresh" size={14} />
                    )}{" "}
                    {pack.sync ? "Tersinkron WhatsApp" : "Perlu diperbarui"}
                  </span>
                </div>
                <Icon name="chevron" />
              </button>
            ))}
          </div>
        ) : (
          <StatePanel state={state} type="pack" retry={() => setState("normal")} />
        )}
      </main>
      <BottomNav view="packs" navigate={navigate} />
    </>
  );
}

function PackEditor({ navigate }: { navigate: (v: View) => void }) {
  const [name, setName] = useState("Daily Mood");
  const [author, setAuthor] = useState("Sticker Studio");
  const [count, setCount] = useState(8);
  const [emojis, setEmojis] = useState(["Smile", "Love"]);
  return (
    <>
      <TopBar
        title="Editor Pack"
        back
        onBack={() => navigate("packs")}
        action={<button className="text-button">Simpan</button>}
      />
      <main className="screen-content editor-form">
        <section className="pack-header-card">
          <button className="tray-icon">
            <StickerArt index={0} />
            <span>
              <Icon name="edit" size={14} />
            </span>
          </button>
          <div>
            <h2>{name || "Tanpa nama"}</h2>
            <p>Tray icon · 96 × 96 px</p>
            <span className="valid-label">
              <Icon name="check" size={14} /> Siap diterbitkan
            </span>
          </div>
        </section>
        <label className="field-label">
          Nama pack
          <input value={name} maxLength={28} onChange={(e) => setName(e.target.value)} />
          <span>{name.length}/28</span>
        </label>
        <label className="field-label">
          Pembuat
          <input value={author} maxLength={28} onChange={(e) => setAuthor(e.target.value)} />
          <span>{author.length}/28</span>
        </label>
        <div className="section-heading compact">
          <div>
            <p className="eyebrow">STIKER</p>
            <h2>Susun pack</h2>
          </div>
          <span className="count-label">{count}/30</span>
        </div>
        <p className="helper-text">Tekan dan tahan untuk mengatur ulang.</p>
        <div className="pack-edit-grid">
          {Array.from({ length: count }, (_, i) => (
            <button key={i} className="edit-sticker" onClick={() => navigate("imageEditor")}>
              <StickerArt index={i} />
              <span>{i + 1}</span>
            </button>
          ))}
          <button className="add-sticker" onClick={() => setCount(Math.min(30, count + 1))}>
            <Icon name="plus" />
            <small>Tambah</small>
          </button>
        </div>
        <section className="emoji-picker">
          <div>
            <b>Tag emoji</b>
            <span>Maks. 3</span>
          </div>
          <div className="emoji-tags">
            {["Smile", "Love", "Party", "Work"].map((e) => (
              <button
                className={emojis.includes(e) ? "active" : ""}
                onClick={() =>
                  setEmojis((v) =>
                    v.includes(e) ? v.filter((x) => x !== e) : v.length < 3 ? [...v, e] : v,
                  )
                }
                key={e}
              >
                {emojis.includes(e) && <Icon name="check" size={14} />} {e}
              </button>
            ))}
          </div>
        </section>
        <section className="validation-card">
          <div className={count >= 3 ? "ok" : ""}>
            <Icon name={count >= 3 ? "check" : "close"} size={16} />
            <span>Minimal 3 stiker</span>
          </div>
          <div className={count <= 30 ? "ok" : ""}>
            <Icon name="check" size={16} />
            <span>Maksimal 30 stiker</span>
          </div>
        </section>
        <button className="whatsapp-button" disabled={count < 3}>
          <span>W</span> Tambah ke WhatsApp
        </button>
      </main>
    </>
  );
}

const editorTools = [
  { id: "textEditor" as View, label: "Teks", icon: "text" },
  { id: "brush" as const, label: "Kuas", icon: "brush" },
  { id: "removeBg" as View, label: "Hapus BG", icon: "erase" },
  { id: "border" as View, label: "Border", icon: "border" },
  { id: "sticker" as const, label: "Stiker", icon: "sticker" },
];

function ImageEditor({ navigate }: { navigate: (v: View) => void }) {
  const [tool, setTool] = useState("select");
  const [layersOpen, setLayersOpen] = useState(false);
  return (
    <div className="editor-shell">
      <TopBar
        title="Edit stiker"
        back
        onBack={() => navigate("library")}
        action={
          <button className="primary-button small" onClick={() => navigate("packEditor")}>
            Selesai
          </button>
        }
      />
      <div className="editor-actionbar">
        <button className="icon-button">
          <Icon name="undo" />
        </button>
        <button className="icon-button muted">
          <Icon name="redo" />
        </button>
        <button
          className={`icon-button ${layersOpen ? "selected" : ""}`}
          onClick={() => setLayersOpen(!layersOpen)}
        >
          <Icon name="layers" />
        </button>
      </div>
      <main className="canvas-area">
        <div className="canvas-grid" />
        <div className="canvas-sticker">
          <StickerArt index={2} />
          <span className="handle tl" />
          <span className="handle tr" />
          <span className="handle bl" />
          <span className="handle br" />
        </div>
        <div className="zoom-label">82%</div>
        {layersOpen && (
          <section className="layer-panel">
            <div>
              <b>Layer</b>
              <button className="icon-button" onClick={() => setLayersOpen(false)}>
                <Icon name="close" size={18} />
              </button>
            </div>
            <button>
              <span className="layer-thumb">
                <StickerArt index={2} small />
              </span>
              <b>Stiker utama</b>
              <Icon name="more" />
            </button>
            <button>
              <span className="layer-thumb text-layer">T</span>
              <b>Teks</b>
              <Icon name="more" />
            </button>
          </section>
        )}
      </main>
      <nav className="editor-toolbar">
        {editorTools.map((t) => (
          <button
            key={t.label}
            className={tool === t.label ? "active" : ""}
            onClick={() => {
              setTool(t.label);
              if (t.id !== "brush" && t.id !== "sticker") navigate(t.id);
            }}
          >
            <span>
              <Icon name={t.icon} />
            </span>
            <small>{t.label}</small>
          </button>
        ))}
      </nav>
    </div>
  );
}

function TextEditor({ navigate }: { navigate: (v: View) => void }) {
  const [font, setFont] = useState("Montserrat");
  const [style, setStyle] = useState("Outline");
  const [color, setColor] = useState("#282522");
  return (
    <div className="editor-shell">
      <TopBar
        title="Editor Teks"
        back
        onBack={() => navigate("imageEditor")}
        action={
          <button className="text-button" onClick={() => navigate("imageEditor")}>
            Terapkan
          </button>
        }
      />
      <main className="text-canvas">
        <div
          className="text-preview"
          style={{ color, fontFamily: font === "Inter" ? "Inter" : "Montserrat" }}
        >
          <span className={style.toLowerCase()}>
            GOOD
            <br />
            DAY!
          </span>
          <i />
          <i />
        </div>
      </main>
      <section className="control-drawer">
        <div className="input-preview">
          <input defaultValue="GOOD DAY!" />
          <span>9/40</span>
        </div>
        <div className="control-group">
          <label>Font</label>
          <div className="font-row">
            {["Montserrat", "Inter", "Serif"].map((f) => (
              <button
                className={font === f ? "active" : ""}
                onClick={() => setFont(f)}
                key={f}
                style={{ fontFamily: f === "Serif" ? "Georgia" : f }}
              >
                {f === "Montserrat" ? "Aa" : f === "Inter" ? "Ag" : "Ab"}
                <small>{f}</small>
              </button>
            ))}
          </div>
        </div>
        <div className="control-group">
          <label>Preset gaya</label>
          <div className="style-row">
            {["Outline", "Shadow", "Latar"].map((s) => (
              <button className={style === s ? "active" : ""} onClick={() => setStyle(s)} key={s}>
                {s}
              </button>
            ))}
          </div>
        </div>
        <div className="control-group">
          <label>Warna</label>
          <div className="color-row">
            {["#282522", "#ffffff", "#8d7bd6", "#dc8e78", "#e6c65a", "#78a78b"].map((c) => (
              <button
                aria-label={`Warna ${c}`}
                className={color === c ? "active" : ""}
                onClick={() => setColor(c)}
                key={c}
                style={{ background: c }}
              >
                {color === c && <Icon name="check" size={15} />}
              </button>
            ))}
          </div>
        </div>
      </section>
    </div>
  );
}

function RemoveBackground({ navigate }: { navigate: (v: View) => void }) {
  const [mode, setMode] = useState("Erase");
  const [size, setSize] = useState(42);
  const [feather, setFeather] = useState(18);
  return (
    <div className="editor-shell">
      <TopBar
        title="Hapus Background"
        back
        onBack={() => navigate("imageEditor")}
        action={
          <button className="text-button" onClick={() => navigate("imageEditor")}>
            Terapkan
          </button>
        }
      />
      <main className="remove-canvas">
        <div className="checker" />
        <div className="subject-art">
          <StickerArt index={6} />
        </div>
        <div className="brush-cursor" style={{ width: size, height: size }} />
        <div className="loupe">
          <div className="checker" />
          <StickerArt index={6} small />
          <i />
        </div>
      </main>
      <section className="control-drawer remove-controls">
        <div className="mode-toggle">
          <button className={mode === "Erase" ? "active" : ""} onClick={() => setMode("Erase")}>
            <Icon name="erase" /> Erase
          </button>
          <button className={mode === "Restore" ? "active" : ""} onClick={() => setMode("Restore")}>
            <Icon name="brush" /> Restore
          </button>
        </div>
        <Range label="Ukuran kuas" value={size} setValue={setSize} suffix=" px" />
        <Range label="Feather" value={feather} setValue={setFeather} suffix="%" />
      </section>
    </div>
  );
}

function Range({
  label,
  value,
  setValue,
  suffix,
}: {
  label: string;
  value: number;
  setValue: (n: number) => void;
  suffix: string;
}) {
  return (
    <label className="range-control">
      <span>
        <b>{label}</b>
        <i>
          {value}
          {suffix}
        </i>
      </span>
      <input
        type="range"
        min="0"
        max="100"
        value={value}
        onChange={(e) => setValue(Number(e.target.value))}
        style={{ "--range": `${value}%` } as React.CSSProperties}
      />
    </label>
  );
}

function BorderEditor({ navigate }: { navigate: (v: View) => void }) {
  const [width, setWidth] = useState(12);
  const [feather, setFeather] = useState(8);
  const [color, setColor] = useState("#ffffff");
  return (
    <div className="editor-shell">
      <TopBar
        title="Border Stiker"
        back
        onBack={() => navigate("imageEditor")}
        action={
          <button className="text-button" onClick={() => navigate("imageEditor")}>
            Terapkan
          </button>
        }
      />
      <main className="border-canvas">
        <div className="checker" />
        <div
          className="border-preview"
          style={{ filter: `drop-shadow(0 0 ${feather / 4}px ${color})` }}
        >
          <div style={{ WebkitTextStroke: `${Math.max(3, width / 3)}px ${color}` }}>
            <StickerArt index={4} />
          </div>
        </div>
        <span>Preview {width}px</span>
      </main>
      <section className="control-drawer border-controls">
        <Range label="Ketebalan" value={width} setValue={setWidth} suffix=" px" />
        <Range label="Feather" value={feather} setValue={setFeather} suffix="%" />
        <div className="control-group">
          <label>Warna border</label>
          <div className="color-row">
            {["#ffffff", "#282522", "#e5d7ff", "#f4c9bb", "#d6ecdf"].map((c) => (
              <button
                className={color === c ? "active" : ""}
                onClick={() => setColor(c)}
                key={c}
                style={{ background: c }}
              >
                {color === c && <Icon name="check" size={15} />}
              </button>
            ))}
          </div>
        </div>
      </section>
    </div>
  );
}

function Settings({
  navigate,
  dark,
  setDark,
}: {
  navigate: (v: View) => void;
  dark: boolean;
  setDark: (v: boolean) => void;
}) {
  return (
    <>
      <TopBar title="Settings" />
      <main className="screen-content settings-page">
        <section className="profile-card">
          <div className="app-mark">
            <Icon name="sticker" size={30} />
          </div>
          <div>
            <h2>Sticker Studio</h2>
            <p>Ringan. Privat. Milikmu.</p>
          </div>
          <span>v1.4.0</span>
        </section>
        <p className="group-title">TAMPILAN</p>
        <section className="settings-group">
          <div className="setting-row">
            <span className="setting-icon">
              <Icon name={dark ? "moon" : "sun"} />
            </span>
            <div>
              <b>Mode gelap</b>
              <small>Soft reverse theme</small>
            </div>
            <button className={`switch ${dark ? "on" : ""}`} onClick={() => setDark(!dark)}>
              <span />
            </button>
          </div>
          <button className="setting-row">
            <span className="setting-icon">
              <Icon name="palette" />
            </span>
            <div>
              <b>Tema aplikasi</b>
              <small>Soft Light · Natural</small>
            </div>
            <Icon name="chevron" />
          </button>
        </section>
        <p className="group-title">EXTENSION MANAGER</p>
        <section className="settings-group">
          <button className="setting-row">
            <span className="setting-icon">
              <Icon name="type" />
            </span>
            <div>
              <b>Font</b>
              <small>6 font terpasang</small>
            </div>
            <span className="mini-action">
              <Icon name="plus" size={16} /> Impor
            </span>
          </button>
          <button className="setting-row">
            <span className="setting-icon">
              <Icon name="border" />
            </span>
            <div>
              <b>Preset gaya</b>
              <small>12 preset tersimpan</small>
            </div>
            <span className="mini-action">
              <Icon name="plus" size={16} /> Impor
            </span>
          </button>
          <button className="setting-row">
            <span className="setting-icon">
              <Icon name="palette" />
            </span>
            <div>
              <b>Tema</b>
              <small>2 tema terpasang</small>
            </div>
            <Icon name="chevron" />
          </button>
        </section>
        <p className="group-title">DATA LOKAL</p>
        <section className="settings-group">
          <button className="setting-row">
            <span className="setting-icon">
              <Icon name="upload" />
            </span>
            <div>
              <b>Backup</b>
              <small>Ekspor pack dan pengaturan</small>
            </div>
            <Icon name="chevron" />
          </button>
          <button className="setting-row">
            <span className="setting-icon">
              <Icon name="download" />
            </span>
            <div>
              <b>Restore</b>
              <small>Pulihkan dari file backup</small>
            </div>
            <Icon name="chevron" />
          </button>
          <div className="storage-row">
            <div>
              <span>
                <Icon name="database" size={18} /> Penyimpanan
              </span>
              <b>428 MB / 2 GB</b>
            </div>
            <div className="storage-track">
              <i />
            </div>
          </div>
        </section>
        <p className="settings-footnote">Semua data disimpan offline pada perangkat ini.</p>
      </main>
      <BottomNav view="settings" navigate={navigate} />
    </>
  );
}

export default function App() {
  const [view, setView] = useState<View>("library");
  const [dark, setDark] = useState(false);
  const content = useMemo(() => {
    const props = { navigate: setView };
    switch (view) {
      case "gallery":
        return <Gallery {...props} />;
      case "queue":
        return <Queue {...props} />;
      case "packs":
        return <Packs {...props} />;
      case "packEditor":
        return <PackEditor {...props} />;
      case "imageEditor":
        return <ImageEditor {...props} />;
      case "textEditor":
        return <TextEditor {...props} />;
      case "removeBg":
        return <RemoveBackground {...props} />;
      case "border":
        return <BorderEditor {...props} />;
      case "settings":
        return <Settings {...props} dark={dark} setDark={setDark} />;
      default:
        return <Library {...props} />;
    }
  }, [view, dark]);

  return (
    <div className={dark ? "app-stage dark" : "app-stage"}>
      <div className="ambient ambient-one" />
      <div className="ambient ambient-two" />
      <section className="phone-frame">{content}</section>
    </div>
  );
}
