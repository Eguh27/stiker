package com.example.sticker_studio.data

object ImportQueueSchema {
    const val DATABASE_RELATIVE_PATH = "app_data/sticker_studio.sqlite"
    const val ORIGINALS_RELATIVE_PATH = "app_data/originals"

    const val TABLE_NAME = "import_queue"

    const val CREATE_TABLE = """
        CREATE TABLE IF NOT EXISTS import_queue (
            id TEXT NOT NULL,
            source_url TEXT,
            local_input_path TEXT,
            source_type TEXT NOT NULL,
            status TEXT NOT NULL,
            progress INTEGER NOT NULL,
            error_message TEXT,
            auto_rmbg INTEGER NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            PRIMARY KEY (id),
            CHECK (source_type IN (
                'GALLERY_SHARE', 'GALLERY_PICKER', 'PINTEREST',
                'GENERIC_URL', 'DIRECT_IMAGE_LINK', 'MANUAL_FILE'
            )),
            CHECK (status IN (
                'PENDING', 'DOWNLOADING', 'PROCESSING', 'FAILED', 'DONE'
            ))
        )
    """
}
