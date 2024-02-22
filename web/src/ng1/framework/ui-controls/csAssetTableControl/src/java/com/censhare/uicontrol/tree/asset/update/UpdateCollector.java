/*
 * Copyright (c) by censhare AG
 */
package com.censhare.uicontrol.tree.asset.update;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.censhare.model.corpus.impl.AssetCacheKey;
import com.censhare.support.util.logging.ContextLogger;

/**
 * We want to avoid that too many updates for the tree are send to the client
 * because often multiple update events arrive in a very short time.
 *
 * This class will collect the update requests and fire the client update after e.g. 400 milliseconds.
 *
 * @author Christof Aenderl
 */
public final class UpdateCollector {

    public static final int DELAY = 400;

    private static final Logger logger = ContextLogger.getLogger(UpdateCollector.class);

    private final Updater updater;

    private final ScheduledExecutorService scheduler = Executors.newSingleThreadScheduledExecutor();
    private final Set<Long> changes = new HashSet<>();
    private final AtomicBoolean isFullRebuild = new AtomicBoolean(false);

    private Future future;

    public UpdateCollector(Updater updater) {
        this.updater = updater;
    }

    public void addUpdate(long id) {
        if (id < 1) {
            logger.info(() -> "Adding update for negative asset id which will be ignored: " + id);
            return;
        }

        cancel();
        synchronized (changes) {
            changes.add(id);
        }
        trigger();
    }

    public void addUpdates(List<AssetCacheKey> keys) {
        if (keys == null || keys.isEmpty())
            return;

        cancel();
        List<Long> ids = new ArrayList<>(keys.size());
        keys.forEach(key -> ids.add(key.id));
        synchronized (changes) {
            changes.addAll(ids);
        }
        trigger();
    }

    public void requestFullRebuild() {
        cancel();
        isFullRebuild.set(true);
        trigger();
    }

    private synchronized void cancel() {
        if (future != null) {
            future.cancel(false); // don't interrupt running process
            future = null; // always set to null so a new job will be created
        }
    }

    private synchronized void trigger() {
        // if processing is already running we create a new future
        if (future == null)
            future = scheduler.schedule(() -> {
                future = null; // process started, should create a new job for next trigger

                try {
                    if (isFullRebuild.compareAndSet(true, false)) {
                        synchronized (changes) {
                            changes.clear();
                        }

                        updater.fullRebuild();
                    } else {
                        List<Long> allChanges;
                        synchronized (changes) {
                            allChanges = new ArrayList<>(changes); // create copy
                            changes.clear();
                        }

                        updater.rowsUpdate(allChanges);
                    }
                } catch (InterruptedException e) {
                    // empty
                } catch (Exception e) {
                    //savotex custom -> disable error notifier for frontend
                    //https://youtrack.savotex.com/issue/ORTCONTENT-541
                    //updater.notifyError(e);
                    logger.log(Level.WARNING, "failed to load table update", e);
                }
            }, DELAY, TimeUnit.MILLISECONDS);
    }

    synchronized void release() {
        cancel();
        scheduler.shutdownNow();
    }

    @Override
    protected void finalize() throws Throwable {
        release();
        super.finalize();
    }

    public interface Updater {
        void fullRebuild() throws Exception;
        void rowsUpdate(List<Long> changes) throws Exception;
        void notifyError(Exception e);
    }
}
