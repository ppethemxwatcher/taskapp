//
//  ViewController.swift
//  taskapp
//
//  Created by swiftdev on 2016/03/17.
//  Copyright © 2016年 kiyoko.ohashi. All rights reserved.
//

import UIKit
import RealmSwift //追加

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //Realmインスタンスを取得する
    let realm = try! Realm() //追加
    
    //DB内のタスクが格納されるリスト
    //日付近い順でソート：降順
    //以降内容をアップデートするとリスト内は自動的に更新される。
    let taskArray = try! Realm().objects(Task).sorted("date", ascending: false) //追加
    var searchActive : Bool = false //課題追加
    var filteredArray = try! Realm().objects(Task).sorted("date", ascending: false) //課題追加
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        searchBar?.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    //MARK: UITableViewDataSourceプロトコルのメソッド
    //データの数（セルの数）を変えるメソッド
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       if(searchActive) {
        return filteredArray.count
       } else {
        return taskArray.count //追加
        }
    }
    
    //各セルの内容を返すメソッド
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //再利用可能なcellを得る
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        //Cellに値を設定する
        if(searchActive) {
            let task = filteredArray[indexPath.row]
            cell.textLabel?.text = task.title

            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            let dateString:String = formatter.stringFromDate(task.date)
            cell.detailTextLabel?.text = dateString
            
        } else {
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title

        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.stringFromDate(task.date)
        cell.detailTextLabel?.text = dateString
        }
        return cell
        }
    
    //MARK: UITableViewDelegateプロトコルのメソッド
    //各セルを選択した時に実行されるメソッド
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("cellSegue", sender: nil)//追加する
    }
    
    //セルが削除可能なことを伝えるメソッド
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath)->UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    //Deleteボタンが押された時に呼ばれるメソッド
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            //ローカル通知をキャンセルする
            let task = taskArray[indexPath.row]
            
            for notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
                if notification.userInfo!["id"] as! Int == task.id {
                    UIApplication.sharedApplication().cancelLocalNotification(notification)
                    
                    break
                }
            }
            
            //データベースから削除する
            try! realm.write{
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        }
    }
    //segueで画面遷移する時に呼ばれる
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let inputViewController:InputViewController = segue.destinationViewController as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            task.date = NSDate()
            
            if taskArray.count != 0 {
                task.id = taskArray.max("id")! + 1
            }
            inputViewController.task = task
        }
    }
    
    //入力画面から戻ってきた時にTableViewを更新させる
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    //課題追加　検索
    func searchBar(searchBar: UISearchBar, textDidChange searchText:String){
        filteredArray = realm.objects(Task).filter("category contains '\(searchBar.text!)'").sorted("date", ascending: false)
        tableView.reloadData()
    }
}