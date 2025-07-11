// SPDX-License-Identifier: BUSL
pragma solidity ^0.8.28;

library SnapshotsLib {
    struct Snapshots {
        uint256[] timestamps;
        mapping(uint256 timestap => Snapshot) snapshots;
    }

    struct Snapshot {
        bytes32 value;
        uint256 timestamp;
    }

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    error StaleTimestamp();

    /*//////////////////////////////////////////////////////////////
                             VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Retrieves the value of the last snapshot.
     * @return The value of the closest snapshot, converted to `int256`.
     */
    function getLastAsInt(Snapshots storage snapshots) internal view returns (int256) {
        return getAsInt(snapshots, block.timestamp);
    }

    /**
     * @notice Retrieves the value of the closest snapshot with a timestamp less than or equal to `since`.
     * @param since The timestamp to find the closest snapshot for.
     * @return The value of the closest snapshot, converted to `int256`.
     */
    function getAsInt(Snapshots storage snapshots, uint256 since) internal view returns (int256) {
        return int256(uint256(get(snapshots, since)));
    }

    /**
     * @notice Retrieves the value of the last snapshot.
     * @return The value of the closest snapshot.
     */
    function getLast(Snapshots storage snapshots) internal view returns (bytes32) {
        return get(snapshots, block.timestamp);
    }

    /**
     * @notice Retrieves the value of the closest snapshot with a timestamp less than or equal to `since`.
     * @param since The timestamp to find the closest snapshot for.
     * @return The value of the closest snapshot.
     */
    function get(Snapshots storage snapshots, uint256 since) internal view returns (bytes32) {
        uint256 length = snapshots.timestamps.length;
        if (length == 0) return 0;

        uint256 lastTimestamp = snapshots.timestamps[length - 1];
        if (lastTimestamp <= since) return snapshots.snapshots[lastTimestamp].value;
        if (since < snapshots.timestamps[0]) return 0;

        uint256 min = 0;
        uint256 max = length - 1;
        while (max > min) {
            uint256 mid = (max + min + 1) / 2; // Midpoint
            if (snapshots.timestamps[mid] <= since) {
                min = mid; // Narrow down to the upper half
            } else {
                max = mid - 1; // Narrow down to the lower half
            }
        }
        return snapshots.snapshots[snapshots.timestamps[min]].value; // Return the closest checkpoint value
    }

    /*//////////////////////////////////////////////////////////////
                                LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Sets a new snapshot with a given `int256` value and the current block timestamp.
     * @param value The `int256` value to store in the snapshot.
     */
    function setAsInt(Snapshots storage snapshots, int256 value) internal {
        setAsInt(snapshots, value, block.timestamp);
    }

    /**
     * @notice Sets a new snapshot with a given `int256` value and a specific timestamp.
     * @param value The `int256` value to store in the snapshot.
     * @param timestamp The timestamp to associate with the snapshot.
     */
    function setAsInt(Snapshots storage snapshots, int256 value, uint256 timestamp) internal {
        set(snapshots, bytes32(uint256(value)), timestamp);
    }

    /**
     * @notice Sets a new snapshot with a given `bytes32` value and the current block timestamp.
     * @param value The `bytes32` value to store in the snapshot.
     */
    function set(Snapshots storage snapshots, bytes32 value) internal {
        set(snapshots, value, block.timestamp);
    }

    /**
     * @notice Sets a new snapshot with a given `bytes32` value and a specific timestamp.
     * @param value The `bytes32` value to store in the snapshot.
     * @param timestamp The timestamp to associate with the snapshot.
     */
    function set(Snapshots storage snapshots, bytes32 value, uint256 timestamp) internal {
        uint256[] storage array = snapshots.timestamps;
        if (array.length > 0) {
            uint256 lastTimestamp = array[array.length - 1];
            if (timestamp < lastTimestamp) revert StaleTimestamp();
            if (timestamp == lastTimestamp) {
                // update
                snapshots.snapshots[timestamp].value = value;
                return;
            }
        }

        // add
        snapshots.snapshots[timestamp] = Snapshot(value, timestamp);
        snapshots.timestamps.push(timestamp);
    }
}
